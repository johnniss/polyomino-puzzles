:Class polyPane  ⍝ Makes a pane on a subform with a rotating polyomino  xcv
    
    :Field Public pane 
    :Field Public poly 
                       

    ⍝ :include  #.polyFns   ⍝Util dfdfg

    ⍝ :include #.polyDB.guinames 

    ⍝ #.polyFns.GUInames
     
    ∇ new(subform polyominoid)
      :Access Public 
      :Implements Constructor 
      
       #.polyFns.GUInames
      
      :If subform≡⍬
          gform←subform makeformu2 100 100   ⍝ make a new subform
          pane←gform.subforms[0;0]          ⍝ pane fills the whole of tha subform
      :Else
          pane←subform                      ⍝ use the subform given
      :EndIf
     
      scaleit 3
     
      pane.Event←('MouseEnter' 'rotate&')('MouseLeave' 'stoprot&')('MouseDown' 'rotate&')
     
      poly←⎕NEW #.polyominod(polyominoid)
      drawit
    ∇
      
    ∇ autorotate
     
      :Repeat
          poly.turn
          poly.draw pane
          ⎕DL 0.03
      :Until 0
    ∇

    ∇ scaleit scalefac
      :Access Public
     
      pane.XRange←scalefac×1 ¯1
      pane.(YRange←XRange×-Aspect)
    ∇

    ∇ drawit
     
      poly.draw pane
      pane.Visible←1
     
      rotstop←1
    ∇
      

    ∇ rotate msg                        ⍝ Make a piece rotate
      rotstop←1
      :Hold 'rotpane'
          rotstop←0
          :Repeat
              poly.turn
              poly.draw pane
              ⎕DL 0.03
          :Until rotstop=1
      :Else
          ⍝leave dont bother
      :EndHold
    ∇
    

    ∇ stoprot msg
      rotstop←1
    ∇

   
       
:endClass
