:Class polyConveyer  ⍝ Coveyer belt with polyominoes moving right to left and turning
     
    :field Public started  
    :field Public CV 
    :field Public SET
    :field Public polyhit
    :field Public CallEnvir 


    ∇ new(Conveyer polyset caller)      ⍝ Subform for conveyer and vector of polyominoes
      :Access Public 
      :Implements Constructor
     
      :With Conveyer.plines←Conveyer.⎕NEW'Poly'(⊂'Points'(2 2⍴0 0 30 30))
          Coord FCol←'user'(⊂192 192 192)
          FStyle FillCol LStyle←0 0 0
      :EndWith
      Conveyer.Event←('MouseDown' 'Shoot&')
      Conveyer.(YRange←(¯1 1)×5.5)              ⍝ maybe function of formsize and the pieces
      Conveyer.(XRange←(11 0)÷Aspect)
⍝      ⎕←Conveyer.Aspect
      xdisplacement←⊃Conveyer.XRange
      CV←Conveyer
      SET←⊃polyset
      CallEnvir←caller
      started←0
      rotate←1
     ⍝ istop←0
      totcount←⍴SET
     
      :With CV.startstop←CV.⎕NEW'Button'(⊂'Caption' 'Start')
          FontObj←'ARIAL' 15
          Size←24 54
          Posn←0 0
          Style←'Check'
      :EndWith
      CV.startstop.Event←'Select' 'conveyerstop&'            ⍝ When conveyer stop is activ
      CV.startstop.State←0
     
      :With CV.rotate←CV.⎕NEW'Button'(⊂'Caption' 'No rot')
          FontObj←'ARIAL' 15
          Size←24 54
          Posn←0 55
          Style←'Check'
      :EndWith
      CV.rotate.Event←'Select' 'rotatestop&'            ⍝ When conveyer stop is activ
      CV.rotate.State←0
    ∇
    

    ∇ Shoot msg;pos;yxpos;dif;min;xpos;hit                          ⍝ Call back from mouse down
      :Access Public ⍝ override
     
      pos←2↑2↓msg                                                     ⍝ Coordinates of point
      dif←CV.(-/¨YRange XRange)                                       ⍝ Length of ranges
      min←CV.(⌊/¨YRange XRange)                                       ⍝ Upper left corner
      yxpos←((pos÷CV.Size)×|dif)+min                                  ⍝ Position in polygon coordinates
      xpos←xdisplacement-1⊃yxpos
      xranges←{{(⊃⌊⌿⍵)(⊃⌈⌿⍵)}0 1↓⊃,[0]/⍵}¨visibles.polygons
      hit←xpos{(⍺>0⊃⍵)∧(⍺<1⊃⍵)}¨xranges
      ⍝ (hit/xranges)(hit/⍳⍴visibles)
      polyhit←hit/visibles
      :If 0<⍴polyhit
          CallEnvir.notify⊃polyhit.(polyid filcol)               ⍝ Notify which polyomino was selected
      :Else
          ⎕←msg
      :EndIf
    ∇
      

    ∇ z←start;i;j;v;temp                  ⍝ Callback, Chosen envelope box, Init coveyer belt
      :Access Public 
     
      visibles←⍬
      :For i :In ⍳totcount     ⍝ Run the conveyer
          temp←⎕NEW #.polyominod(,⊂i⊃SET)
          temp.polyid←i
          visibles,←temp ⍝ polyconveyx((i⊃SET)(,i)) ⍝ New instance into the back of visible list
          :If 10<⍴visibles                                   ⍝ Max 10 active polys visible at a time
              visibles←1↓visibles                                              ⍝ Remove first element
          :EndIf
          CV.plines.FillCol←0                           ⍝ Reinitialize polygons
          CV.plines.Points←2 2⍴0 0 1 1
          :For j :In ⍳50+250×i=totcount-1                     ⍝ Let the last roll over the scene
              CV.plines.Points←⊃,/visibles.polygons
              CV.plines.FillCol←⊃,/visibles.polycols
              visibles.shiftturn rotate
              ⎕DL 0.05    ⍝02                                       ⍝ machine dependent
          :EndFor
          :While started=0                                   ⍝ Make small delays while on pause
              ⎕DL 1
          :EndWhile
      :EndFor
      z←0
    ∇
     
                    
    ∇ rotatestop msg                                   ⍝ Callback from  conveyer rotate stop/restart button
      :If CV.rotate.Caption≡'No rot'
          :Hold 'focus'
              CV.rotate.Caption←'Rotate'
              CV.rotate.State←0
              rotate←0
          :EndHold
      :ElseIf CV.rotate.Caption≡'Rotate'
          :Hold 'focus'
              CV.rotate.Caption←'No rot'
              CV.rotate.State←0
              rotate←1
          :EndHold
      :EndIf
    ∇
    

    ∇ conveyerstop msg;d                                  ⍝ Callback from  conveyer  stop/restart button
      :If CV.startstop.Caption≡'Start'
          :Hold 'focus'
              CV.startstop.Caption←'Pause'
              CV.startstop.State←0
              started←1
          :EndHold
          d←start
          :Hold 'focus'
              CV.startstop.Caption←'Start'
              CV.startstop.State←0
              started←0
          :EndHold
      :ElseIf CV.startstop.Caption≡'Pause'
          :Hold 'focus'
              CV.startstop.Caption←'Run'
              CV.startstop.State←0
              started←0
          :EndHold
      :ElseIf CV.startstop.Caption≡'Run'
          :Hold 'focus'
              CV.startstop.Caption←'Pause'
              CV.startstop.State←0
              started←1
          :EndHold
      :EndIf
    ∇

    :class xx     ⍝ Makes a polyomino to a conveyer belt and shift and rotate it
           ⍝
⍝        :field shift←0                       ⍝ Horisontal position an external conveyer 
⍝        :field Public polyominoid←0            ⍝ Index of poly in an external collection 
⍝     
⍝
⍝        ∇ new(poly polyid)                            ⍝ Adds polyominoid as atribute
⍝          :Access Public 
⍝         
⍝          polyominoid←polyid
⍝         
⍝          dim←1⊃⍴poly
⍝          :If dim≥4
⍝              poly←(dimreduct⍣(dim-3))poly      ⍝ 4D (or more) polyominos are converted to 3D
⍝          :EndIf
⍝         
⍝          :Implements Constructor :base ,⊂poly   
⍝        ∇
⍝   
⍝   
⍝        ∇ turnx rotate                         ⍝ Shifts and turns the polymino a little on external conveyer
⍝          :Access Public 
⍝          :If rotate=0
⍝              poly3d                              ⍝ Generate polygons
⍝          :ElseIf rotate=1
⍝              turn
⍝          :Else
⍝              phi←360|phi-3×rotate                ⍝ Turn 3 deggrees in rotation mode
⍝              poly3d                              ⍝ Generate polygons
⍝          :End
⍝          shift+←0.1                          ⍝ Increment the position
⍝          polygons←polygons{⍺+[1]0,⍵}¨shift   ⍝ Shift the polygons with accumulated amount
⍝        ∇
⍝     
⍝          dimreduct←{  ⍝ Slice polyomino along first axis an place them allong second axes, with one space between the slices
⍝              d2←1⊃2+⌈⌿⍵                      ⍝ second dimension +1
⍝              res←((2↑[1]⍵)+.×d2 1),2↓[1]⍵
⍝              res[;⍋⌈⌿res]                    ⍝ turn the polyomino into ordered dimensions
⍝          }
⍝      
    :endClass


:endClass
