:class  polySporadic            ⍝ Instances are polyominoes, with volume>11 and outside the library
                                ⍝ The instances are maintained in pdb.sporadicPieces and numbered by pdb.sporadicNo
    :field Public vol
    :field Public dim 
    :field Public number    ⍝ An ordinal number, counting all sporadics 
    :field Public polyomino
    :field Public date

    ∇ new(sculpture)
      :Access Public
      :Implements Constructor
     
      polyomino←rowsort adr2normal sculpture
      vol dim←⍴polyomino
      number←#.pdb.sporadicNo
      #.pdb.sporadicNo+←1
      date←6↑⎕TS
    ∇
    
    ∇ res←pvd(pno pvol pdim)
      :Access Public
     
      :If number vol dim≡pno pvol pdim
          res←polyomino
      :Else
          res←⍬
      :EndIf
    ∇ 
    
      ∇ empty              ⍝ Make a dummy instance
      :Access Public
      :Implements Constructor 
       vol←0
    ∇
             
      adrbox←{⍝ Returns the dimensions of the envelope box
          1+⌈⌿⍵
      }
      
      adr2normal←{⍝ moves polyomino so lower left boxcorner is origo
          ⍵-[1]⌊⌿⍵
      }

      rowsort←{⍝ Sort rows in a matrix
          ⍵[⍋⍵;]
      }

:endClass
