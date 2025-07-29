Remove-Item ./build/nestris.o -erroraction 'silentlycontinue'
ca65 nestris.asm -o ./build/nestris.o --debug-info
Remove-Item ./build/nestris_bck.nes -erroraction 'silentlycontinue'
Move-Item ./build/nestris.nes ./build/nestris_bck.nes -erroraction 'silentlycontinue'
Remove-Item ./build/nestris.dbg -erroraction 'silentlycontinue'
ld65 ./build/nestris.o -o ./build/nestris.nes -t nes --dbgfile ./build/nestris.dbg