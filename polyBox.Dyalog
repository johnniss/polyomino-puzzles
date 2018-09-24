:class  polyBox                   ⍝ Instances are puzzle-boxes of either normal regular or sculptured shape 

    :field Public name
    :field Public sculpture 
    :field Public box 
    :field Public type
    :field Public date

    ∇ new(namex sculptx)
      :Access Public
      :Implements Constructor
     
      name←namex
      sculpture←rowsort adr2normal sculptx
      box←adrbox sculpture
     
      :If sculpture≡↑,⍳box
          sculpture←⍬
          type←'Box'
      :Else
          type←'Sculpture'
      :EndIf
      date←⎕TS
    ∇
     
    ∇ newbox(bx by bz)
      :Access Public
      :Implements Constructor
     
      name←⍕bx by bz
      sculpture←⍬
      box←bx by bz
      type←'Box'
      date←⎕TS
    ∇
   
    ∇ new4Dbox(bx by bz bw)
      :Access Public
      :Implements Constructor 
     
      :If bw=0
          newbox(bx by bz)
      :Else
          name←⍕bx by bz bw
          sculpture←⍬
          box←bx by bz bw
          type←'Hyperbox'
          date←⎕TS
      :EndIf
    ∇ 
    
    ∇ new5Dbox(bx by bz bw bu)
      :Access Public
      :Implements Constructor 
     
      :If bu=0
          new4Dbox(bx by bz bw)
      :Else
          name←⍕bx by bz bw bu
          sculpture←⍬
          box←bx by bz bw bu
          type←'Hyperbox'
          date←⎕TS
      :EndIf
    ∇    
    
    ∇ empty              ⍝ Make a dummy instance
      :Access Public
      :Implements Constructor 
      name←'Blank'
    ∇
    
    ∇ res←volume
      :Access Public  
     
      :If type≡'Sculpture'
          res←≢sculpture
      :Else
          res←⊃×/box
      :EndIf
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
