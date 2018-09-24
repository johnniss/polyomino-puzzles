:class utilSolution

    :Field Public name               ⍝ the puzzlname
    :Field Public starttime
    :Field Public duration 
    :Field Public box
    :Field Public piececount 
    :Field Public columnnames
    :Field Public placementserie           ⍝ 3 column Array of timestamps, placements id color 
       

    ∇ new puzlinstance
      :Access Public     
      :Implements Constructor 
     
      name starttime duration box←puzlinstance.(puzzlename starttime curdur boxdim)
      columnnames←'Freezetime placement polyomino color'
      placementserie←↑(1↓puzlinstance.pieces).(freezetime freezeplacement(volume dimension globalid)pfc)
      placementserie{⍺[⍋⍺[;⍵];]}←0     ⍝ Sort by first column=freezetime
     
      piececount←≢placementserie
    ∇
  
    ∇ copy(puzlinstance dumy)
      :Access Public     
      :Implements Constructor 
      ⍝ ⎕←'sn' shownames puxx
      name starttime duration box←puzlinstance.(name starttime duration box)
      piececount columnnames placementserie←puzlinstance.(piececount columnnames placementserie)
    ∇ 
    
      ∇ empty              ⍝ Make a dummy instance
      :Access Public
      :Implements Constructor 
      name←'Blank'
    ∇
       
:endClass
