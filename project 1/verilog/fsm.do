vlib work
vlog FSM.v FSMTB.v +cover -covercells
vsim -voptargs=+acc work.FSMTB -cover
add wave *
coverage save FSMTB.ucdb -onexit
run -all