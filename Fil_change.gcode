M412 S0 ; disable filament runout sensor


M204 S9000
{if toolchange_count > 1 && (z_hop_types[current_extruder] == 0 || z_hop_types[current_extruder] == 3)}
G17

G2 Z{z_after_toolchange + 0.4} I0.86 J0.86 P1 F10000 ; spiral lift a little from second lift

{endif}
G1 Z{max_layer_z + 3.0} F1200

; start 3D Chameleon - unload except first tool change



{if previous_extruder>-1}
    {if previous_extruder!=next_extruder}
        G1 X30 Y0 F21000; move to holding location for cutter
        M400
        G92 E0 ; reset extruder
        G1 E-15 ; retract a little filament
        G1 Y-3 ; move all the way to the front to the cutter
        M400

        M109 S255

        ; move to cutter and cut
        G1 X0 F500 ; press cutter slowly
        M400
        G1 E-1 F21000
        G1 X15 F21000
        M400
        G1 X0 F21000
        M400
        G1 E-1 F21000
        M400
        G1 X60 F21000
        M400

        G1 Y0
        M400

        G92 E0
        G1 E10 F10000

        G92 E0
        G1 E-75 F10000

        G4  
        T{next_extruder}

        ; safely move to waiting position switch
        G1 Y200
        M400
        G1 X0
        M400
        G1 Y240
        M400

        G1 Y250 F2000 ; press button

        {if next_extruder==0}
            G4 P550 ; dwell for .5 seconds - adjust this to match your machines single pulse time
        {endif}
        {if next_extruder==1}
            G4 P1050 ; dwell for 1.0 seconds - adjust this to match your machines two pulse time
        {endif}
        {if next_extruder==2}
            G4 P1550 ; dwell for 1.5 seconds - adjust this to match your machines three pulse time
        {endif}
        {if next_extruder==3}
            G4 P2050 ; dwell for 2.0 seconds - adjust this to match your machines four pulse time
        {endif}

        ; back off button 
        G1 Y240 F21000
        M400
        G4 S1

        ; press button to unload 20 inches
        G1 Y250
        G4 S20 ;  20 second unload
        G1 Y240
        M400

        G4 S1

        ; press button to load 22 inches (20 + 2)
        G1 Y250
        G4 S20 ;  20 second unload
        {if previous_extruder>-1}
            G4 S2 ; two additional seconds for first load
        {endif}
        G1 Y240
        M400

        G4 S1

        G1 E30 F500 ; preload the extruder before purge

        ; end 3DChameleon
    {endif}

    G1 X54 F21000
    G1 Y265 F21000
    M400
    M106 P1 S0
    M106 P2 S0
    {if old_filament_temp > 142 && next_extruder < 255}
        M104 S[old_filament_temp]
    {endif}
    G1 X90 F3000
    G1 Y255 F4000
    G1 X100 F5000
    G1 X120 F15000
    G1 X54 F21000
    G1 Y265 F21000

    ;M620.1 X F21000
    T[next_extruder]
    ;M620.1 E F{new_filament_e_feedrate}
    ; always use highest temperature to flush
    M400
    M109 S[nozzle_temperature_range_high]
    M400
    {if next_extruder < 255}
        M400

        G92 E0
        {if flush_length_1 > 1}
            ; FLUSH_START
            {if flush_length_1 > 23.7}
                G1 E23.7 F{old_filament_e_feedrate} ; do not need pulsatile flushing for start part
                G1 E{(flush_length_1 - 23.7) * 0.02} F50
                G1 E{(flush_length_1 - 23.7) * 0.23} F{old_filament_e_feedrate}
                G1 E{(flush_length_1 - 23.7) * 0.02} F50
                G1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}
                G1 E{(flush_length_1 - 23.7) * 0.02} F50
                G1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}
                G1 E{(flush_length_1 - 23.7) * 0.02} F50
                G1 E{(flush_length_1 - 23.7) * 0.23} F{new_filament_e_feedrate}
            {else}
                G1 E{flush_length_1} F{old_filament_e_feedrate}
            {endif}
            ; FLUSH_END
            G1 E-[old_retract_length_toolchange] F1800
            G1 E[old_retract_length_toolchange] F300
        {endif}
        ; FLUSH_START
        M400
        M109 S[new_filament_temp]
        G1 E2 F{new_filament_e_feedrate} ;Compensate for filament spillage during waiting temperature
        ; FLUSH_END
        M400
        G92 E0
        G1 E-[new_retract_length_toolchange] F1800
        M106 P1 S255
        M400 S3
        G1 X80 F15000
        G1 X60 F15000
        G1 X80 F15000
        G1 X60 F15000; shake to put down garbage

        G1 X70 F5000
        G1 X90 F3000
        G1 Y255 F4000
        G1 X100 F5000
        G1 Y265 F5000
        G1 X70 F10000
        G1 X100 F5000
        G1 X70 F10000
        G1 X100 F5000
        G1 X165 F15000; wipe and shake
        G1 Y256 ; move Y to aside, prevent collision
        M400
        G1 Z[z_after_toolchange] F3000
        {if layer_z <= (initial_layer_print_height + 0.001)}
            M204 S[initial_layer_acceleration]
        {else}
            M204 S[default_acceleration]
        {endif}
    {else}
        G1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F12000
    {endif}

{endif}
M412 S1