#!/bin/bash

# Headers
main_header() {
    echo "VirtualBox TUI"
    separator_header
}
vm_header() {
    echo "VM: $vm_selected"
    vboxmanage showvminfo "$vm_selected_uuid" | grep -e '^State:'
    separator_header
}
separator_header() {
    echo "--------------"
}

# Functions
list_vms() { # Lists VMs for selection
    clear
    main_header
    vm_list=$(vboxmanage list vms --sorted)
    if [ -z "$vm_list" ]; then
        echo "No VMs found"
        separator_header
        vm_list_selected=$(gum choose \
            "Refresh" \
            "Exit")
        case $vm_list_selected in
            "Refresh")
                list_vms;;
            "Exit")
                exit 0;;
        esac
    else
        echo "Select a VM:"
        separator_header
        vm_selected=$(gum choose --limit=1 <<< "$vm_list")
        vm_selected_uuid=$(echo "$vm_selected" | \
            awk '{print $(NF)}' | \
            sed -e 's/^{//' -e 's/}$//')
        stat_vm
    fi
}

stat_vm() { # Single VM view
    clear
    main_header
    vm_header
    echo "VM Actions:"
    separator_header
    list_actions
}

list_actions() { # Actions applicable to single VM
    action_selected=$(gum choose \
        "Start" \
        "Pause" \
        "Resume" \
        "Reboot" \
        "Stop" \
        "Manage" \
        "Refresh" \
        "Home" \
        "Exit")
    case $action_selected in
        "Start")
            list_start_options;;
        "Pause")
            gum confirm \
                --default="no" \
                "Pause VM?" \
                && \
                gum spin \
                    --title="Pausing VM..." \
                    --show-output \
                    -- vboxmanage controlvm "$vm_selected_uuid" pause
            list_vms;;
        "Resume")
            gum spin \
                --title="Resuming VM..." \
                --show-output \
                -- vboxmanage controlvm "$vm_selected_uuid" resume
            list_vms;;
        "Reboot")
            list_reboot_options;;
        "Stop")
            list_stop_options;;
        "Manage")
            list_manage_options;;
        "Refresh")
            stat_vm;;
        "Home")
            list_vms;;
        "Exit")
            exit 0;;
    esac
}

list_start_options() { # VM start options
    clear
    main_header
    vm_header
    echo "VM Start Options:"
    separator_header
    start_option_selected=$(gum choose \
        "Normal" \
        "Headless" \
        "Detachable")
    case $start_option_selected in
        "Normal")
            gum spin \
                --title="Starting VM normally..." \
                --show-output \
                -- vboxmanage startvm "$vm_selected_uuid" --type=gui
            list_vms;;
        "Headless")
            gum spin \
                --title="Starting VM headless..." \
                --show-output \
                -- vboxmanage startvm "$vm_selected_uuid" --type=headless
            list_vms;;
        "Detachable")
            gum spin \
                --title="Starting VM detachable..." \
                --show-output \
                -- vboxmanage startvm "$vm_selected_uuid" --type=separate
            list_vms;;
    esac
}

list_reboot_options() { # VM reboot options
    clear
    main_header
    vm_header
    echo "VM Reboot Options:"
    separator_header
    reboot_option_selected=$(gum choose \
        "Safe (Requires Guest Additions)" \
        "Force")
    case $reboot_option_selected in
        "Safe (Requires Guest Additions)")
            gum confirm \
                --default="no" \
                "Reboot VM safely?" \
                && \
                gum spin \
                    --title="Rebooting VM safely..." \
                    --show-output \
                    -- vboxmanage controlvm "$vm_selected_uuid" reboot
            list_vms;;
        "Force")
            gum confirm \
                --default="no" \
                "Force-reboot VM?" \
                && \
                gum spin \
                    --title="Force-rebooting VM..." \
                    --show-output \
                    -- vboxmanage controlvm "$vm_selected_uuid" reset
            list_vms;;
    esac
}

list_stop_options() { # VM stop options
    clear
    main_header
    vm_header
    echo "VM Stop Options:"
    separator_header
    stop_option_selected=$(gum choose \
        "Safe (Requires Guest Additions)" \
        "ACPI" \
        "Force" \
        "Save State")
    case $stop_option_selected in
        "Safe (Requires Guest Additions)")
            gum confirm \
                --default="no" \
                "Stop VM safely?" \
                && \
                gum spin \
                    --title="Stopping VM safely..." \
                    --show-output \
                    -- vboxmanage controlvm "$vm_selected_uuid" shutdown
            list_vms;;
        "ACPI")
            gum confirm \
                --default="no" \
                "Press ACPI power button?" \
                && \
                gum spin \
                    --title="Stopping VM with ACPI button press..." \
                    --show-output \
                    -- vboxmanage controlvm "$vm_selected_uuid" acpipowerbutton
            list_vms;;
        "Force")
            gum confirm \
                --default="no" \
                "Force-stop VM?" \
                && \
                gum spin \
                    --title="Force-stopping VM..." \
                    --show-output \
                    -- vboxmanage controlvm "$vm_selected_uuid" poweroff
            list_vms;;
        "Save State")
            gum confirm \
                --default="no" \
                "Save VM state and stop?" \
                && \
                gum spin \
                    --title="Saving VM state and stopping..." \
                    --show-output \
                    -- vboxmanage controlvm "$vm_selected_uuid" savestate
            list_vms;;
    esac   
}

list_manage_options() { # VM manage options
    manage_option_selected=$(gum choose \
        "Snapshots" \
        "Discard State" \
        "Autostart")
    case $manage_option_selected in
        "Snapshots")
            list_snapshot_options;;
        "Discard State")
            gum confirm \
                --default="no" \
                "Discard VM State?" \
                && \
                gum spin \
                    --title="Discarding VM state..." \
                    --show-output \
                    -- vboxmanage discardstate "$vm_selected_uuid"
            list_vms;;
        "Autostart")
            list_autostart_options;;
    esac
}

list_autostart_options() { # VM autostart options
    clear
    main_header
    vm_header
    echo "VM Autostart Options:"
    separator_header
    autostart_option_selected=$(gum choose \
        "Enable" \
        "Disable" \
        "Set Delay")
    case $autostart_option_selected in
        "Enable")
            gum spin \
                --title="Enabling VM autostart..." \
                --show-output \
                -- vboxmanage controlvm "$vm_selected_uuid" autostart-enabled on
            list_vms;;
        "Disable")
            gum spin \
                --title="Disabling VM autostart..." \
                --show-output \
                -- vboxmanage controlvm "$vm_selected_uuid" autostart-disabled off
            list_vms;;
        "Set Delay")
            echo "Enter VM Autostart Delay in Seconds:"
            gum spin \
                --title="Setting VM autostart delay..." \
                --show-output \
                -- vboxmanage controlvm "$vm_selected_uuid" autostart-delay "$(gum input --placeholder="Autostart delay in seconds")"
            list_vms;;
    esac
}

list_snapshot_options() {
    snapshot_option_selected=$(gum choose \
        "Take" \
        "Restore" \
        "Edit" \
        "Delete")
    case $snapshot_option_selected in
        "Take")
            take_snapshot;;
        "Restore")
            restore_snapshot;;
        "Edit")
            edit_snapshot;;
        "Delete")
            delete_snapshot;;
    esac
}

list_snapshots() {
    snapshot_list=$(vboxmanage snapshot "$vm_selected_uuid" list)
    clear
    main_header
    vm_header
    if [ "$snapshot_list" = "This machine does not have any snapshots" ]; then
        echo "No Snapshots Found"
        separator_header
        snapshot_list_selected=$(gum choose \
            "Refresh" \
            "Back to VM" \
            "VM List" \
            "Exit")
        case $snapshot_list_selected in
            "Refresh")
                list_snapshots;;
            "Back to VM")
                stat_vm;;
            "VM List")
                vm_list;;
            "Exit")
                exit 0;;
        esac
    else
        echo "Select Snapshot:"
        separator_header
        snapshot_selected=$(gum choose --limit=1 <<< "$snapshot_list")
        snapshot_selected_uuid=$(echo "$snapshot_selected" | \
            awk '{
                for(i=1; i<=NF; i++) {
                    tmp=match($i, /[A-Za-z0-9]{8}\-[A-Za-z0-9]{4}\-[A-Za-z0-9]{4}\-[A-Za-z0-9]{4}\-[A-Za-z0-9]{12}/)
                    if(tmp) {
                        print $i
                    }
                }
            }' | sed -e 's/)$//')
    fi
}

take_snapshot() {
    clear
    main_header
    vm_header
    echo "Enter Snapshot Name:"
    separator_header
    gum spin \
        --title="Taking Snapshot..." \
        --show-output \
        -- vboxmanage snapshot "$vm_selected_uuid" take \
        "$(gum input --placeholder='My Snapshot')" --live
    list_vms
}

restore_snapshot() {
    clear
    main_header
    vm_header
    list_snapshots
    gum confirm \
        --default="no" \
        "Restore Snapshot?" \
        && \
        gum spin \
            --title="Restoring Snapshot..." \
            --show-output \
            -- vboxmanage snapshot "$vm_selected_uuid" restore "$snapshot_selected_uuid"
    list_vms
}

edit_snapshot() {
    clear
    main_header
    vm_header
    list_snapshots
    echo "Enter New Snapshot Name:"
    separator_header
    gum spin \
        --title="Editing Snapshot..." \
        --show-output \
        -- vboxmanage snapshot "$vm_selected_uuid" edit "$snapshot_selected_uuid" \
        --name="$(gum input --placeholder='My Snapshot')"
    list_vms
}

delete_snapshot() {
    clear
    main_header
    vm_header
    list_snapshots
    gum confirm \
        --default="no" \
        "Delete Snapshot?" \
        && \
        gum spin \
            --title="Deleting Snapshot..." \
            --show-output \
            -- vboxmanage snapshot "$vm_selected_uuid" delete "$snapshot_selected_uuid"
    list_vms
}


# Init
list_vms
