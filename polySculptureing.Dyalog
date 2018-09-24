:Class polySculptureing ⍝ : polyominod      ⍝  Creates a Lego world of polyominoes

    :field Public mainform
    :field Public mainf
    :field Public paint←0 
  
    :Include #.polyFns   ⍝Util

    ∇ new subform
      :Access Public
      :Implements Constructor   
     
      GUIsetup subform
     
      Reset
    ∇
    
    ∇ GUIsetup subform;i
     
      GUInames
     
      ⍝ Mainform setup
      mainform←subform makeformu(5 90 10)(2 96 2)              ⍝ Definiton of main page subform layout
     
      headf←mainform.subforms[0;1]                               ⍝ Shorthand for the main subpanes
      leftf mainf rightf←mainform.subforms[1;]
      botf←mainform.subforms[2;1]
     
      :With headf.Label1←headf.⎕NEW Label(⊂Caption'    Polyomino sculpture')
          FontObj←'ARIAL' 30 ⋄ Size←40 300 ⋄ Posn←10 400
      :EndWith
      
      ⍝:With headf.Label2←headf.⎕NEW Label(⊂Caption'Vol Fragm Ext=')
⍝          FontObj←'ARIAL' 20 ⋄ Size←20 110 ⋄ Posn←20 730
⍝      :EndWith 
⍝      
       :With headf.Label3←headf.⎕NEW Label(⊂Caption'Vol Dim ..')
          FontObj←'ARIAL' 20 ⋄ Size←20 300 ⋄ Posn←20 730
      :EndWith
     
      mainf.Coord←Pixel
      mainf.Event←(MouseDown'Shoot&')(MouseUp'Stop&')
     
      ⍝ Calculating coordinate system
      aspect←⊃÷/mainf.Size
      mainf.(YRange←10×¯1 1)
      mainf.XRange←mainf.YRange÷aspect
      dif←mainf.(-/¨YRange XRange)                                       ⍝ Length of ranges
      min←mainf.(⌊/¨YRange XRange)
     
     
      ⍝ Set Rotation and zoom Butns
      :With butn1←botf.⎕NEW Button(⊂Caption'⍋⍒')
          FontObj←'APL385 Unicode' 20 ⋄ Size←32 32 ⋄ Posn←0 310
      :EndWith
      butn1.Event←(MouseDown'Turn&' 0)(MouseUp'Stop&')
     
      :With butn2←botf.⎕NEW Button(⊂Caption'←→')
          FontObj←'APL385 Unicode' 20 ⋄ Size←32 32 ⋄ Posn←0 390
      :EndWith
      butn2.Event←(MouseDown'Turn&' 1)(MouseUp'Stop&')
     
      zoom←botf.⎕NEW Button(⊂Style Push)
      zoom.FontObj←'ARIAL' 25 ⋄ zoom.Size←32 32 ⋄ zoom.Posn←0 350 ⋄ zoom.Caption←'Zz'
      zoom.Event←(MouseDown'zoominout&')(MouseUp'zoomstop&')
     
     
      ⍝ Selection combo
      sculpCombo←botf.⎕NEW Combo((VScroll ¯1)(Style DropEdit))
      :With sculpCombo
          FontObj←'ARIAL' 25 ⋄ Posn←0 450 ⋄ Size←32 200
          Items←#.pdb.sculptures.name
      :EndWith
      sculpCombo.Event←(Select'selectsculp&')(Change'changesculp&')
     
     
       ⍝ Save + reset buts.
      :With butn3←botf.⎕NEW Button(⊂Caption'Save')
          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 700
      :EndWith
      butn3.Event←(MouseDown'Save&' 0)
     
      :With butn4←botf.⎕NEW Button(⊂Caption'Reset')
          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 900
      :EndWith
      butn4.Event←(MouseDown'Reset&' 1)
     
      :With butn4a←botf.⎕NEW Button(⊂Caption'Delete')
          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 960
      :EndWith
      butn4a.Event←(MouseDown'Delete' 1)
     
      :With butn5←botf.⎕NEW Button(⊂Caption'as Box')
          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 820
      :EndWith
      butn5.Event←(MouseDown'Asbox')
     
      :With butn6←botf.⎕NEW Button(⊂Caption'as Piece')
          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 760
      :EndWith
      butn6.Event←(MouseDown'Aspiece')
     
      ⍝ Color handling palette
⍝      filcol,←shades 1 0 0                            ⍝ red shades       3
⍝      filcol,←shades 1 1 0                            ⍝ yellow shades    6
⍝      filcol,←shades 0 1 0                            ⍝ green shades     9
⍝      filcol,←shades 0 0 1                            ⍝ blue shades      12
⍝      filcol,←shades 1 0 1                            ⍝ pink  shades     15
⍝      filcol,←shades 0 1 1                            ⍝ cyan shades      18
⍝      filcol,←shades 1 1 1                            ⍝ white shades     21
⍝      filcol,←shades 0 0 0                            ⍝ black shades     24
     
      ⍝ Color picker
      palette←150×(0 0 0)(1 0 0)(1 1 0)(0 1 0)(0 0 1)(1 0 1)(0 1 1)(1 1 1)(0 0 0)    ⍝ button bcol
      cb←⍬
      :For i :In ⍳9
          cb,←botf.⎕NEW Button(⊂Caption'')
          cb[i].Size←30 30 ⋄ cb[i].Posn←2(i×30) ⋄ cb[i].Style←'Check'
          :If i>0 ⋄ cb[i].BCol←i⊃palette ⋄ :EndIf
          cb[i].Event←Select'selectcolor&'i
          cb[i].State←0
      :EndFor
      cb[0].State←1        ⍝ default color in but 0
      paint←0
    ∇
   
⍝======================= Callbacks ======================= 

    ∇ Shoot msg;pos;yxpos;hits;hit;count                   ⍝ Call back from mouse down
      :Access Public ⍝ override
     
      pos←2↑2↓msg                                           ⍝ Coordinates of point
      yxpos←⊂((pos÷mainf.Size)×|dif)+min                    ⍝ Position in polygon coordinates                                                            ⍝ Index of the outermost polygon
      stop←0                                              ⍝ If any hit
      :Select 4⊃msg                                         ⍝ Mouse button
      :Case 1       ⍝ Left mouse = add new cell
          hit←0≤paint mainf.poly.addcell yxpos
          :If hit
              mainf.poly.draw mainf
              ⎕DL 0.1
              count←0  
              :While stop=0
                  selfhit←mainf.poly.repeatadd
                  count+←1
                  stop←selfhit∨(count≥20)
                  mainf.poly.draw mainf
                  ⎕DL 0.2
              :EndWhile
          :EndIf
      :Case 2       ⍝ Right mouse = delete or recolor 
         :if vol>1
          paint mainf.poly.delcell yxpos
          mainf.poly.draw mainf 
         :endif
      :EndSelect
      sizeinfo
    ∇
    
    
    ⍝  orbits←{⍝ finds the orbital constituents of a box
⍝          box←⍵   ⍝ [⍋⍵]                                    ⍝ parameter is the shape of the box
⍝          boxcenter←⊂¯0.5+0.5×box
⍝          ↑¨(⊂boxcenter)+{⊃+/⍵*2}eqc(,⍳box)-boxcenter  ⍝ Groups of cells with same dist from boxcenter
⍝      }
⍝      
⍝      orbitsignature←{⍝ finds orbital signature of a piece
⍝          count+/¨(⊂↓⍵)∊¨↓¨orbits adrbox ⍵
⍝      }
     

    ∇ dir Turn msg    ⍝ Make a piece rotate
      :Hold 'stop'
          stop←0
      :EndHold
      leftright←4⊃msg  ⍝ Mousebutton
      :Repeat
          :Select dir leftright
          :Case 0 1
              mainf.poly.turndown
          :Case 1 1
              mainf.poly.turn
          :Case 0 2
              mainf.poly.turnup
          :Case 1 2
              mainf.poly.turnback
          :EndSelect
          mainf.poly.draw mainf
          ⎕DL 0.01
      :Until stop=1
    ∇
    
    ∇ zoominout msg    ⍝ Zoom button
      leftright←4⊃msg  ⍝ Mousebutton
      mainf.YRange+←leftright⌽(¯1 1)
      mainf.XRange←mainf.YRange÷aspect
      dif←mainf.(-/¨YRange XRange)                                       ⍝ Length of ranges
      min←mainf.(⌊/¨YRange XRange)
      mainf.poly.draw mainf
    ∇
    
    ∇ zoomstop msg
      ⍝ ⎕←msg
    ∇
     
    ∇ Save;index;lng                    ⍝ save the graph in pdb.sculptures
      :If 1<≢⊃savename
          index←#.pdb.sculptures.name⍳savename
          lng←≢#.pdb.sculptures
          :If index=lng
              #.pdb.sculptures,←#.⎕NEW #.polySculpture((⊃savename)mainf.poly)
              sculpCombo.Items←#.pdb.sculptures.name
          :Else
              #.pdb.sculptures[index]←#.⎕NEW #.polySculpture((⊃savename)mainf.poly)
          :EndIf
      :Else
          sculpCombo.Text←'Invalid name'
      :EndIf
    ∇
    
    ∇ Delete;index;lng;txt                    ⍝ Delete a graph in pdb.sculptures
      :If 1<≢⊃savename
          index←#.pdb.sculptures.name⍳savename
          lng←≢#.pdb.sculptures
          :If index=lng
              sculpCombo.Text←'Invalid name'
          :Else
              #.pdb.sculptures/⍨←index≠⍳lng
              savename←''
              txt←sculpCombo.Text,'-deleted'
              sculpCombo.Items←#.pdb.sculptures.name
              sculpCombo.Text←txt
          :EndIf
      :Else
          sculpCombo.Text←'Invalid name'
      :EndIf
    ∇
    
    ∇ initform palet
      mainf.poly.draw mainf
      :If palet
          mainf.poly.makepalette
          savename←''
      :EndIf
      cb.State←1,8⍴0
      paint←0
    ∇ 
    
    ∇sizeinfo     ⍝ retrieve size info  from polyd 

     vol box fragments←mainf.poly.sizeinfo    
     headf.Label3.Caption←⍕'Vol' vol 'Dim' (+/box>1) 'Fragm' fragments 'Box' box 
    ∇
    
    ∇ Reset
      mainf.poly←#.⎕NEW #.polyominod(2 1 0)       ⍝ a domino on stage
      initform 1
      sizeinfo
    ∇
    
    ∇ Asbox;index    ⍝ Save as polybox
      :If (⊂savename)∊#.pdb.boxDims.name
          sculpCombo.Text,←', IN USE'
      :Else
          index←#.pdb.sculptures.name⍳savename
          #.pdb.boxDims,←(#.pdb.sculptures[index]).aspolyBox
      :EndIf
    ∇
    
    ∇ Aspiece;piece    ⍝ Save as sporadic polyomino piece
      piece←#.⎕NEW #.polySporadic(,⊂mainf.poly.polyomino)
      #.pdb.sporadicPieces,←piece
    ∇
   
    ∇ Stop msg
      :Hold 'stop'
          stop←1
      :EndHold
    ∇
    
    ∇ pno selectcolor msg
      paint←pno×3
      cb.State←0
      cb[pno].State←1
    ∇
    
    ∇ selectsculp;index;frompolyd      ⍝ Select Sculpture
      index←sculpCombo.(SelItems/⍳⍴SelItems)
      savename←sculpCombo.(SelItems/Items)
      frompolyd←(index⊃#.pdb.sculptures)   ⍝.(polyomino polycols filcol cellcolors)  ⍝ polyd
      frompolyd.(filcol←↓filcol)
      mainf.poly←#.⎕NEW #.polyominod(frompolyd ⍬ ⍬ ⍬ ⍬)
      initform 0  
      sizeinfo
    ∇
    
    ∇ changesculp;t;pos           ⍝ new boxdim entere
      t←sculpCombo.Text
      :If 1<≢t
          :If ∧/t∊'0123456789, '
          :AndIf 3=⍴⍎t
              :If ','∊t
                  pos←t⍳','
                  t1 t2←⍎¨(pos↑t)((pos+1)↓t)
                  :If 1=≢t1
                      mainf.poly←#.⎕NEW #.polyominod(t2,t1)
                  :Else
                      mainf.poly←#.⎕NEW #.polyominod(t1,t2)
                  :EndIf
              :Else
                  boxdim←⍎t
                  mainf.poly←#.⎕NEW #.polyominod(,⊂↑,⍳boxdim)
              :EndIf
              initform 1
          :Else ⍝ a save-name is assumed
              savename←⊂sculpCombo.Text
          :EndIf
      :EndIf 
      sizeinfo
    ∇
 



 ⍝
⍝
⍝:Class polySculptureing ⍝ : polyominod      ⍝  Creates a Lego world of polyominoes
⍝
⍝    :field Public mainform
⍝    :field Public mainf
⍝    :field Public paint←0 
⍝  
⍝    ⍝ :Include #.polyUtil
⍝     :Include #.polyFns
⍝
⍝
⍝    ∇ new subform
⍝      :Access Public
⍝      :Implements Constructor   
⍝     
⍝      GUIsetup subform
⍝     
⍝      Reset
⍝    ∇
⍝    
⍝    ∇ GUIsetup subform;i
⍝     
⍝      GUInames
⍝     
⍝      ⍝ Mainform setup
⍝      mainform←subform makeformu(5 90 10)(2 96 2)              ⍝ Definiton of main page subform layout
⍝     
⍝      headf←mainform.subforms[0;1]                               ⍝ Shorthand for the main subpanes
⍝      leftf mainf rightf←mainform.subforms[1;]
⍝      botf←mainform.subforms[2;1]
⍝     
⍝      :With headf.Label1←headf.⎕NEW Label(⊂Caption'    Polyomino sculpture')
⍝          FontObj←'ARIAL' 30 ⋄ Size←40 300 ⋄ Posn←10 400
⍝      :EndWith
⍝     
⍝      mainf.Coord←Pixel
⍝      mainf.Event←(MouseDown'Shoot&')(MouseUp'Stop&')
⍝     
⍝      ⍝ Calculating coordinate system
⍝      aspect←⊃÷/mainf.Size
⍝      mainf.(YRange←10×¯1 1)
⍝      mainf.XRange←mainf.YRange÷aspect
⍝      dif←mainf.(-/¨YRange XRange)                                       ⍝ Length of ranges
⍝      min←mainf.(⌊/¨YRange XRange)
⍝     
⍝     
⍝      ⍝ Set Rotation and zoom Butns
⍝      :With butn1←botf.⎕NEW Button(⊂Caption'⍋⍒')
⍝          FontObj←'APL385 Unicode' 20 ⋄ Size←32 32 ⋄ Posn←0 310
⍝      :EndWith
⍝      butn1.Event←(MouseDown'Turn&' 0)(MouseUp'Stop&')
⍝     
⍝      :With butn2←botf.⎕NEW Button(⊂Caption'←→')
⍝          FontObj←'APL385 Unicode' 20 ⋄ Size←32 32 ⋄ Posn←0 390
⍝      :EndWith
⍝      butn2.Event←(MouseDown'Turn&' 1)(MouseUp'Stop&')
⍝     
⍝      zoom←botf.⎕NEW Button(⊂Style Push)
⍝      zoom.FontObj←'ARIAL' 25 ⋄ zoom.Size←32 32 ⋄ zoom.Posn←0 350 ⋄ zoom.Caption←'Zz'
⍝      zoom.Event←(MouseDown'zoominout&')(MouseUp'zoomstop&')
⍝     
⍝     
⍝      ⍝ Selection combo
⍝      sculpCombo←botf.⎕NEW Combo((VScroll ¯1)(Style DropEdit))
⍝      :With sculpCombo
⍝          FontObj←'ARIAL' 25 ⋄ Posn←0 450 ⋄ Size←32 200
⍝          Items←#.pdb.sculptures.name
⍝      :EndWith
⍝      sculpCombo.Event←(Select'selectsculp&')(Change'changesculp&')
⍝     
⍝     
⍝       ⍝ Save + reset buts.
⍝      :With butn3←botf.⎕NEW Button(⊂Caption'Save')
⍝          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 700
⍝      :EndWith
⍝      butn3.Event←(MouseDown'Save&' 0)
⍝     
⍝      :With butn4←botf.⎕NEW Button(⊂Caption'Reset')
⍝          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 900
⍝      :EndWith
⍝      butn4.Event←(MouseDown'Reset&' 1)
⍝     
⍝      :With butn4a←botf.⎕NEW Button(⊂Caption'Delete')
⍝          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 960
⍝      :EndWith
⍝      butn4a.Event←(MouseDown'Delete' 1)
⍝     
⍝      :With butn5←botf.⎕NEW Button(⊂Caption'as Box')
⍝          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 820
⍝      :EndWith
⍝      butn5.Event←(MouseDown'Asbox')
⍝     
⍝      :With butn6←botf.⎕NEW Button(⊂Caption'as Piece')
⍝          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←0 760
⍝      :EndWith
⍝      butn6.Event←(MouseDown'Aspiece')
⍝     
⍝      ⍝ Color handling palette
⍝⍝      filcol,←shades 1 0 0                            ⍝ red shades       3
⍝⍝      filcol,←shades 1 1 0                            ⍝ yellow shades    6
⍝⍝      filcol,←shades 0 1 0                            ⍝ green shades     9
⍝⍝      filcol,←shades 0 0 1                            ⍝ blue shades      12
⍝⍝      filcol,←shades 1 0 1                            ⍝ pink  shades     15
⍝⍝      filcol,←shades 0 1 1                            ⍝ cyan shades      18
⍝⍝      filcol,←shades 1 1 1                            ⍝ white shades     21
⍝⍝      filcol,←shades 0 0 0                            ⍝ black shades     24
⍝     
⍝      ⍝ Color picker
⍝      palette←150×(0 0 0)(1 0 0)(1 1 0)(0 1 0)(0 0 1)(1 0 1)(0 1 1)(1 1 1)(0 0 0)    ⍝ button bcol
⍝      cb←⍬
⍝      :For i :In ⍳9
⍝          cb,←botf.⎕NEW Button(⊂Caption'')
⍝          cb[i].Size←30 30 ⋄ cb[i].Posn←2(i×30) ⋄ cb[i].Style←'Check'
⍝          :If i>0 ⋄ cb[i].BCol←i⊃palette ⋄ :EndIf
⍝          cb[i].Event←Select'selectcolor&'i
⍝          cb[i].State←0
⍝      :EndFor
⍝      cb[0].State←1        ⍝ default color in but 0
⍝      paint←0
⍝    ∇
⍝   
⍝⍝======================= Callbacks ======================= 
⍝
⍝    ∇ Shoot msg;pos;yxpos;hits;hit;count                   ⍝ Call back from mouse down
⍝      :Access Public ⍝ override
⍝     
⍝      pos←2↑2↓msg                                           ⍝ Coordinates of point
⍝      yxpos←⊂((pos÷mainf.Size)×|dif)+min                    ⍝ Position in polygon coordinates                                                            ⍝ Index of the outermost polygon
⍝      stop←0                                              ⍝ If any hit
⍝      :Select 4⊃msg                                         ⍝ Mouse button
⍝      :Case 1       ⍝ Left mouse = add new cell
⍝          hit←0≤paint mainf.poly.addcell yxpos
⍝          :If hit
⍝              mainf.poly.draw mainf
⍝              ⎕DL 0.1
⍝              count←0  
⍝              :While stop=0
⍝                  selfhit←mainf.poly.repeatadd
⍝                  count+←1
⍝                  stop←selfhit∨(count≥20)
⍝                  mainf.poly.draw mainf
⍝                  ⎕DL 0.2
⍝              :EndWhile
⍝          :EndIf
⍝      :Case 2       ⍝ Right mouse = delete or recolor
⍝          paint mainf.poly.delcell yxpos
⍝          mainf.poly.draw mainf
⍝      :EndSelect
⍝    ∇
⍝    
⍝    
⍝      orbits←{⍝ finds the orbital constituents of a box
⍝          box←⍵   ⍝ [⍋⍵]                                    ⍝ parameter is the shape of the box
⍝          boxcenter←⊂¯0.5+0.5×box
⍝          ↑¨(⊂boxcenter)+{⊃+/⍵*2}eqc(,⍳box)-boxcenter  ⍝ Groups of cells with same dist from boxcenter
⍝      }
⍝      
⍝      orbitsignature←{⍝ finds orbital signature of a piece
⍝          count+/¨(⊂↓⍵)∊¨↓¨orbits adrbox ⍵
⍝      }
⍝     
⍝
⍝    ∇ dir Turn msg    ⍝ Make a piece rotate
⍝      :Hold 'stop'
⍝          stop←0
⍝      :EndHold
⍝      leftright←4⊃msg  ⍝ Mousebutton
⍝      :Repeat
⍝          :Select dir leftright
⍝          :Case 0 1
⍝              mainf.poly.turndown
⍝          :Case 1 1
⍝              mainf.poly.turn
⍝          :Case 0 2
⍝              mainf.poly.turnup
⍝          :Case 1 2
⍝              mainf.poly.turnback
⍝          :EndSelect
⍝          mainf.poly.draw mainf
⍝          ⎕DL 0.01
⍝      :Until stop=1
⍝    ∇
⍝    
⍝    ∇ zoominout msg    ⍝ Zoom button
⍝      leftright←4⊃msg  ⍝ Mousebutton
⍝      mainf.YRange+←leftright⌽(¯1 1)
⍝      mainf.XRange←mainf.YRange÷aspect
⍝      dif←mainf.(-/¨YRange XRange)                                       ⍝ Length of ranges
⍝      min←mainf.(⌊/¨YRange XRange)
⍝      mainf.poly.draw mainf
⍝    ∇
⍝    
⍝    ∇ zoomstop msg
⍝      ⍝ ⎕←msg
⍝    ∇
⍝     
⍝    ∇ Save;index;lng                    ⍝ save the graph in pdb.sculptures
⍝      :If 1<≢⊃savename
⍝          index←#.pdb.sculptures.name⍳savename
⍝          lng←≢#.pdb.sculptures
⍝          :If index=lng
⍝              #.pdb.sculptures,←#.⎕NEW #.polySculpture((⊃savename)mainf.poly)
⍝              sculpCombo.Items←#.pdb.sculptures.name
⍝          :Else
⍝              #.pdb.sculptures[index]←#.⎕NEW #.polySculpture((⊃savename)mainf.poly)
⍝          :EndIf
⍝      :Else
⍝          sculpCombo.Text←'Invalid name'
⍝      :EndIf
⍝    ∇
⍝    
⍝    ∇ Delete;index;lng;txt                    ⍝ Delete a graph in pdb.sculptures
⍝      :If 1<≢⊃savename
⍝          index←#.pdb.sculptures.name⍳savename
⍝          lng←≢#.pdb.sculptures
⍝          :If index=lng
⍝              sculpCombo.Text←'Invalid name'
⍝          :Else
⍝              #.pdb.sculptures/⍨←index≠⍳lng
⍝              savename←''
⍝              txt←sculpCombo.Text,'-deleted'
⍝              sculpCombo.Items←#.pdb.sculptures.name
⍝              sculpCombo.Text←txt
⍝          :EndIf
⍝      :Else
⍝          sculpCombo.Text←'Invalid name'
⍝      :EndIf
⍝    ∇
⍝    
⍝    ∇ initform palet
⍝      mainf.poly.draw mainf
⍝      :If palet
⍝          mainf.poly.makepalette
⍝          savename←''
⍝      :EndIf
⍝      cb.State←1,8⍴0
⍝      paint←0
⍝    ∇
⍝    
⍝    ∇ Reset
⍝      mainf.poly←#.⎕NEW #.polyominod(2 1 0)       ⍝ a domino on stage
⍝      initform 1
⍝    ∇
⍝    
⍝    ∇ Asbox;index    ⍝ Save as polybox
⍝      :If (⊂savename)∊#.pdb.boxDims.name
⍝          sculpCombo.Text,←', IN USE'
⍝      :Else
⍝          index←#.pdb.sculptures.name⍳savename
⍝          #.pdb.boxDims,←(#.pdb.sculptures[index]).aspolyBox
⍝      :EndIf
⍝    ∇
⍝    
⍝    ∇ Aspiece;piece    ⍝ Save as sporadic polyomino piece
⍝      piece←#.⎕NEW #.polySporadic(,⊂mainf.poly.polyomino)
⍝      #.pdb.sporadicPieces,←piece
⍝    ∇
⍝   
⍝    ∇ Stop msg
⍝      :Hold 'stop'
⍝          stop←1
⍝      :EndHold
⍝    ∇
⍝    
⍝    ∇ pno selectcolor msg
⍝      paint←pno×3
⍝      cb.State←0
⍝      cb[pno].State←1
⍝    ∇
⍝    
⍝    ∇ selectsculp;index;frompolyd      ⍝ Select Sculpture
⍝      index←sculpCombo.(SelItems/⍳⍴SelItems)
⍝      savename←sculpCombo.(SelItems/Items)
⍝      frompolyd←(index⊃#.pdb.sculptures).polyd
⍝      mainf.poly←#.⎕NEW #.polyominod(frompolyd ⍬ ⍬ ⍬ ⍬)
⍝      initform 0
⍝    ∇
⍝    
⍝    ∇ changesculp;t;pos           ⍝ new boxdim entere
⍝      t←sculpCombo.Text
⍝      :If 1<≢t
⍝          :If ∧/t∊'0123456789, '
⍝          :AndIf 3=⍴⍎t
⍝              :If ','∊t
⍝                  pos←t⍳','
⍝                  t1 t2←⍎¨(pos↑t)((pos+1)↓t)
⍝                  :If 1=≢t1
⍝                      mainf.poly←#.⎕NEW #.polyominod(t2,t1)
⍝                  :Else
⍝                      mainf.poly←#.⎕NEW #.polyominod(t1,t2)
⍝                  :EndIf
⍝              :Else
⍝                  boxdim←⍎t
⍝                  mainf.poly←#.⎕NEW #.polyominod(,⊂↑,⍳boxdim)
⍝              :EndIf
⍝              initform 1
⍝          :Else ⍝ a save-name is assumed
⍝              savename←⊂sculpCombo.Text
⍝          :EndIf
⍝      :EndIf
⍝    ∇
⍝ 
⍝:endClass  

:endClass
