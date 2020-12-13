

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /SPRITE_PROCESS_tb/status
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/CLKA
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/ADDRA
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/DINA
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/WEA
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/DOUTA
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/CLKB
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/ADDRB
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/DINB
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/WEB
      waveform add -signals /SPRITE_PROCESS_tb/SPRITE_PROCESS_synth_inst/bmg_port/DOUTB

console submit -using simulator -wait no "run"
