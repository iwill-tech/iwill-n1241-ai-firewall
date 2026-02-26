#!/bin/sh
# PROVIDE: es_repair
# REQUIRE: FILESYSTEMS
# BEFORE: elasticsearch
# KEYWORD: nojail
#
# es_repair - Auto-repair Elasticsearch + Zenarmor after power cuts
# Handles: ES datastore, stale locks, filesystem corruption, Zenarmor settings.db
# Deploy to: /usr/local/etc/rc.d/es_repair
# Then: chmod +x /usr/local/etc/rc.d/es_repair

. /etc/rc.subr

name="es_repair"
rcvar="es_repair_enable"
start_cmd="es_repair_start"
stop_cmd=":"

ES_DIR="/usr/local/datastore/elasticsearch"
ES_USER="elasticsearch"
ES_GROUP="elasticsearch"
ZEN_DB="/usr/local/zenarmor/userdefined/config/settings.db"
ZEN_DB_BACKUP="/usr/local/zenarmor/userdefined/config/settings.db.good"
LOG="/var/log/es-repair.log"

es_repair_start() {
    echo "$(date): === Boot Repair Started ===" >> $LOG

    # ---------------------------------------------------------------
    # 1. FILESYSTEM CHECK — fix soft-update inconsistencies from power cut
    # ---------------------------------------------------------------
    echo "$(date): Running background fsck on /dev/gpt/rootfs" >> $LOG
    fsck_ffs -B -y /dev/gpt/rootfs >> $LOG 2>&1 || true

    # ---------------------------------------------------------------
    # 2. ELASTICSEARCH DATASTORE — ensure directory + permissions
    # ---------------------------------------------------------------
    if [ ! -d "$ES_DIR" ]; then
        echo "$(date): MISSING: Creating ES datastore directory" >> $LOG
        mkdir -p "$ES_DIR"
    fi
    chown -R ${ES_USER}:${ES_GROUP} "$ES_DIR"
    chmod 750 "$ES_DIR"
    echo "$(date): ES directory OK: $ES_DIR" >> $LOG

    # Remove stale lock file (left behind by dirty shutdown)
    if [ -f "$ES_DIR/node.lock" ]; then
        echo "$(date): STALE LOCK: Removing node.lock" >> $LOG
        rm -f "$ES_DIR/node.lock"
    fi

    # ---------------------------------------------------------------
    # 3. ZENARMOR SETTINGS.DB — check integrity, restore if corrupt
    # ---------------------------------------------------------------
    if [ -f "$ZEN_DB" ]; then
        # Test if SQLite DB is readable
        if sqlite3 "$ZEN_DB" "SELECT count(*) FROM interface_settings;" > /dev/null 2>&1; then
            echo "$(date): Zenarmor settings.db OK — creating backup" >> $LOG
            cp -f "$ZEN_DB" "$ZEN_DB_BACKUP"
        else
            echo "$(date): CORRUPT: Zenarmor settings.db is malformed!" >> $LOG
            if [ -f "$ZEN_DB_BACKUP" ]; then
                echo "$(date): RESTORING: settings.db from last known good backup" >> $LOG
                cp -f "$ZEN_DB_BACKUP" "$ZEN_DB"
                # Regenerate workers.map from restored DB
                if [ -x /usr/local/zenarmor/py_venv/bin/python3 ]; then
                    /usr/local/zenarmor/py_venv/bin/python3 /usr/local/opnsense/scripts/OPNsense/Zenarmor/worker_template.py >> $LOG 2>&1
                    echo "$(date): Regenerated workers.map from restored settings.db" >> $LOG
                fi
            else
                echo "$(date): NO BACKUP: settings.db corrupt and no good backup exists. Zenarmor will need manual setup." >> $LOG
            fi
        fi
    else
        echo "$(date): MISSING: settings.db does not exist. Zenarmor may need initial setup." >> $LOG
    fi

    # ---------------------------------------------------------------
    # 4. ZENARMOR WORKERS.MAP — ensure it exists
    # ---------------------------------------------------------------
    WORKERS_MAP="/usr/local/zenarmor/etc/workers.map"
    if [ ! -f "$WORKERS_MAP" ] || [ ! -s "$WORKERS_MAP" ]; then
        echo "$(date): MISSING/EMPTY: workers.map — attempting regeneration" >> $LOG
        if [ -x /usr/local/zenarmor/py_venv/bin/python3 ]; then
            /usr/local/zenarmor/py_venv/bin/python3 /usr/local/opnsense/scripts/OPNsense/Zenarmor/worker_template.py >> $LOG 2>&1
            echo "$(date): Regenerated workers.map" >> $LOG
        fi
    fi

    echo "$(date): === Boot Repair Complete ===" >> $LOG
}

load_rc_config $name
: ${es_repair_enable:=YES}
run_rc_command "$1"
