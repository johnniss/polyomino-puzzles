:Class polyXray       ⍝  Polyomino x-ray app page
   
    :include #.polyFns    

    ∇ new subform;voldim;color
      :Access Public 
      :Implements Constructor 
     
      guisetup subform
     
      voldim color←↓¨(2⊃#.pdb.baseCollections).(voldimid color)        ⍝ Filling the windows initially
      coll←voldim{⎕NEW #.polyominod(⍺,⊂⍵)}¨color
      matrixdraw coll
    ∇

     
    ∇ guisetup subform
     
      GUInames
     
      mainform←subform makeformu(5 35 8 50 2)(5 90 5)       ⍝ Definiton of main page subform layout
     
      controlpanel←mainform.subforms[2;1]                                    ⍝ Shorthand for the main subpanes
      viewpanel←mainform.subforms[1;1]
      reportf←mainform.subforms[3;1]
      headf←mainform.subforms[0;1]
     
      headLabel←headf.⎕NEW Label(⊂Caption'X-Ray machine')
      :With headLabel
          FontObj←'ARIAL' 30 ⋄ Size←30 200 ⋄ Posn←12 450
      :EndWith
     
      five←viewpanel makeformu(1 98 1)(1 15 1 15 3 30 3 15 1 15 1)
     
      fivepanes←five.subforms[1;1 3 5 7 9]
      smallfour←five.subforms[1;1 3 7 9]
      smallfour.(Size÷←2 1)
      smallfour.(Posn+←(⊃Size÷2)0)
     
      ⍝ scalefac←3
     
      :For ix :In 1 3 5 7 9
          ssf←five.subforms[1;ix]
          ssf.XRange←3 ¯3
          :If ix=5
              ssf.(YRange←XRange×-Aspect)
          :Else
              ssf.(YRange←XRange×-0.5×Aspect)
          :EndIf
          ssf.Event←(MouseEnter'rotate&'ssf)(MouseLeave'stoprot&')(MouseDown'rotate&'ssf)
      :EndFor
     
      collCombo←controlpanel.⎕NEW Combo((VScroll ¯1)(Style DropEdit))
      :With collCombo
          FontObj←'ARIAL' 20 ⋄ Posn←10 10 ⋄ Size←25 160
          Items←#.pdb.(baseCollections,userCollections).name,⊂'Sculptures'
      :EndWith
      collCombo.Event←(Select'selectcoll&')(Change'expr&')
     
      backward←controlpanel.⎕NEW Button(⊂Style Push)
      forward←controlpanel.⎕NEW Button(⊂Style Push)
     
      sculpName←controlpanel.⎕NEW Label(⊂Caption' ')
      :With sculpName
          FontObj←'ARIAL' 20 ⋄ Posn←10 430 ⋄ Size←30 150
      :EndWith
     
      backward←controlpanel.⎕NEW Button(⊂Style Push)
      forward←controlpanel.⎕NEW Button(⊂Style Push)
     
      :For i :In 0 1
          Cap←i⊃backward forward
          Cap.FontObj←'ARIAL' 25 ⋄ Cap.Size←30 50 ⋄ Cap.Posn←10(i⊃375 650) ⋄ Cap.Caption←i⊃'←→'
          Cap.Event←⊂Select'forthandback&'(i⊃¯1 1)
      :EndFor
     
      zoom←controlpanel.⎕NEW Button(⊂Style Push)
      zoom.FontObj←'ARIAL' 25 ⋄ zoom.Size←30 50 ⋄ zoom.Posn←10 590 ⋄ zoom.Caption←'Z'
      zoom.Event←(MouseDown'zoominout&')(MouseUp'zoomstop&')
     
      :With reportpanel←reportf.⎕NEW Edit((Style Multi)(VScroll ¯1)(HScroll ¯1)(FieldType Char))
          FontObj←'APL385 Unicode' 15 ⋄ Size←##.Size ⋄ Posn←0 0
      :EndWith
    ∇
    
     ⍝-------------------- Callbacks --------------------------------------------- 
    
    ∇ selectcoll;index;voldim;color      ⍝ Select collection
     
      index←collCombo.(SelItems/⍳⍴SelItems)
      collname←collCombo.Text
      :If collname≡'Sculptures'
          collection←#.pdb.sculptures.polyd
          sculpnames←#.pdb.sculptures.name
          source←'Sculptures'
     ⍝ :Elseif
⍝          voldim color←↓¨(index⊃#.pdb.(baseCollections,userCollections)).(voldimid color)
⍝          collection←voldim{⎕NEW #.polyominod(⍺,⊂⍵)}¨color
⍝          source←'Collections'
      :Else
          voldim color←↓¨(index⊃#.pdb.(baseCollections,userCollections)).(voldimid color)
          collection←voldim{⎕NEW #.polyominod(⍺,⊂⍵)}¨color
          source←'Collections'
      :EndIf
      collection←⍬ ⍬,collection,⍬ ⍬
      piececount←≢collection
      firstpiece←0
      piecesetup
    ∇
    
    ∇ expr
      collname←collCombo.Text
      ⎕←'col a'collname
      :If 1↑collname∊':>'
          ⎕←'col'collname
          exprescoll←⍎1↓collname
          collection←{⎕NEW #.polyominod(,⊂⍵)}¨exprescoll
          source←'Expression'
          collection←⍬ ⍬,collection,⍬ ⍬
          piececount←≢collection
          firstpiece←0
          piecesetup
      :EndIf
    ∇
    
    ∇ zoominout msg
      leftright←4⊃msg
      ssf←five.subforms[1;5]
      :If leftright=1
          ssf.XRange-←1 ¯1
      :Else
          ssf.XRange+←1 ¯1
      :EndIf
      ssf.(YRange←XRange×-Aspect)
      ssf.poly.draw ssf
    ∇
    
    ∇ zoomstop msg
      ⍝ ⎕←msg
    ∇
    
    ∇ sign forthandback msg  ⍝ Back and forth one piece at a time
     
      firstpiece+←sign
      firstpiece⌈←0
      firstpiece⌊←0⌈piececount-5
     
      piecesetup
    ∇
    
    ∇ ssf rotate msg                        ⍝ Make a piece rotate
      rotstop←1
      :Hold 'rotation'
          rotstop←0
          :Repeat
              ssf.poly.turn
              ssf.poly.draw ssf
              ⎕DL 0.01
          :Until rotstop=1
      :Else
      ⍝leave dont bother
      :EndHold
    ∇

    ∇ stoprot msg
      rotstop←1
    ∇
    
   ⍝========================= Util ======================= 
                                   
    ∇ matrixdraw polys;ix
      ix←0
      :For ssf :In fivepanes
          :If ⍬≢ix⊃polys
              ssf.poly←ix⊃polys
              ssf.poly.draw ssf
              ssf.Visible←1
          :Else
              ssf.Visible←0
          :EndIf
          ix+←1
      :EndFor
     
      rotstop←1
    ∇

    ∇ piecesetup  ⍝ Draw the visible part of the collecton and makes a report on centerpiece
      :If source≡'Sculptures'
          sculpName.Caption←'  ',firstpiece⊃sculpnames
      :ElseIf source≡'Collections'
          sculpName.Caption←'  ',⍕(1+firstpiece)('of')(¯4+≢collection)
      :ElseIf source≡'Expression'
          sculpName.Caption←'  jnh '
          sculpName.Caption←'  ',⍕(1+firstpiece)('of')(¯4+≢collection)
      :EndIf
      coll←collection[firstpiece+⍳5]
      matrixdraw coll
      centerpiece←(2+firstpiece)⊃collection
      report
    ∇
  
    ⍝=========================== Report window ==============================================
    
    ∇ report;a;t;poly;realpoly
     
      dpx←{⍝ Display 20 char width heading
          lng←≢⍺
          string←((⌈lng÷20)20)⍴(lng+20)↑⍺
          dpz⍪string ⍵
      }
     
      dpy←{⍝ Display variable width heading
          string←↑⍺
          dpz⍪string ⍵
      }
     
      dpz←{⍝ Display without outer frameing
          ¯1 ¯1↓(1 1)↓DISPLAY ⍵
      }
     
      adrbox←{⍝ Returns the dimensions of the envelope box
          1+⌈⌿⍵
      }
     
      adr2normal←{⍝ moves polyomino so lower left ccould be origo
          ⍵-[1]⌊⌿⍵
      }
     
     ⍝ cubesignature←{ ⍝ Signature that count subcubes of a polyomino=⍵ zz
⍝     
⍝          countparts←{
⍝              firsts←2≢/⍵[⍋↑⍵]                          ⍝ unik firstmarks of ordered rows
⍝              freq←-2-/(1,firsts,1)/⍳2+⍴firsts          ⍝ dist between firsts is freq
⍝              cm←(1+⌈/freq)⍴0
⍝              cm[freq]+←1
⍝              cm
⍝          }
⍝          dim←1⊃⍴⍵
⍝          stdcubes←↓¨dim⊃#.pdb.stdcubes
⍝          ⍉↑countparts¨⍪/stdcubes∘.+⊂¨↓2×⍵                             ⍝  (1 ¯1)↓
⍝      }
     
    ⍝  show←{
⍝          deko←' ┌┐─┬└│├┼┘┼┼┤┴┼'
⍝          wtype←(0 0 0)(0 0 1)(0 1 0)(0 1 1)(0 1 2)(1 0 0)(1 0 1)(1 0 2)
⍝          wtype,←(1 1 0)(1 1 1)(1 1 2)(1 2 0)(1 2 1)(1 2 2)(1 2 3)
⍝          dim←1⊃⍴⍵
⍝          adr2bitmap←{(⍳adrbox ⍵)∊↓⍵}
⍝          subshow←{
⍝              box←1 2×⍴⍵
⍝              rewrap←¯1⌽¯1⊖(box+2)↑box⍴up 2\¨,⍵
⍝              deko[{wtype⍳⊂1↓(∪⍵)⍳⍵}¨⊃{2,/[⍺]⍵}/0 1 rewrap]
⍝          }
⍝          dim<2:subshow adr2bitmap 0,⍵
⍝          dim=2:subshow adr2bitmap ⍵
⍝          subshow¨⊂[¯2↑⍳dim]adr2bitmap ⍵
⍝      }
     
   ⍝   chiral←{⍝ Returns 1 if polyomino is chiral else 0
⍝          dim←1⊃⍴⍵
⍝          dim<2:0
⍝          mirror←⍵                         ⍝ Make a mirror image of polyomino ⍵
⍝          mirror[;¯1+dim]×←¯1             ⍝ Changing sign on last column
⍝          ¯0.5×¯1+4⊃⍵ #.polyFns.adrdif mirror        ⍝ Sign of transformations converted into boolean
⍝      }
     
      orbits←{⍝ finds the orbital constituents of a box
          box←⍵   ⍝ [⍋⍵]                                    ⍝ parameter is the shape of the box
          boxcenter←⊂¯0.5+0.5×box
          ↑¨(⊂boxcenter)+{⊃+/⍵*2}eqc(,⍳box)-boxcenter  ⍝ Groups of cells with same dist from boxcenter
      }
     
      orbitsignature←{⍝ finds orbital signature of a piece
          count+/¨(⊂↓⍵)∊¨↓¨orbits adrbox ⍵
      }
     
      nabosignature←{ ⍝ Optæller nabo-forgreninger
          count nabocount ⍵
      }
     
      count←{⍝ Count indexes
          a←(1+⌈/⍵)⍴0 ⋄ a[⍵]+←1 ⋄ a
      }
     
      naboorden←{⍝ Order rows after nabodist
          ⍵[⍋nabodist ⍵;]
      }
     
      nabodist←{⍝ Distance vector for each unit to all other units in polyomino, sorted by size and stacked in unit-order
          ↑{⍵[⍋⍵]}¨↓+/¨|(↓⍵)∘.-↓⍵
      }
     
      nabocount←{⍝ For each cell count neighbours (dist=1)
          +/1=+/¨|(↓⍵)∘.-↓⍵
      }
     
      ⍝--------- The report window contents ---------------------------------
     
      :If source≡'Collections'
          poly vol dim no←centerpiece.(polyomino vol dim index)
          realpoly←⊃no pvd vol dim       ⍝ Unlifted version directly from the libary
      :ElseIf source≡'Expression'
          poly←realpoly←firstpiece⊃exprescoll
          vol dim←⍴poly
          no←(pvd vol dim)⍳⊂poly
      :Else
          poly←adr2normal centerpiece.polyomino
          vol←≢poly
          realpoly dim no←poly 3 '?'
      :EndIf
     
      a←⊂'Volume Dimension No'dpx(vol dim no)
      :If dim≥3
          a,←⊂'Envelope box'dpx adrbox realpoly
      :Else
          a,←⊂'Envelope box        Lifted and base'dpx adrbox¨poly realpoly
      :EndIf
      :If vol<20
          a,←⊂'2D drawing'dpx show realpoly
      :Else
          a,←⊂'2D drawing, too big'dpx show⊃0 pvd 1 0
      :EndIf
      a,←⊂'Chiral dimension'dpx,dim×chirality realpoly
      a,←⊂'Is an array'dpx,poly≡↑,⍳adrbox poly
      :If dim≥3
          a,←⊂'Cube adress vectors'dpx(⍪⍳≢poly)realpoly
      :Else
          a,←⊂'Cube adress vectors Lifted and base'dpx(⍪⍳≢poly)poly realpoly
      :EndIf
      a,←⊂'Neigbour count'dpx⍪¨(⍳≢poly)(nabocount poly)
      a,←⊂'Neigbour signature'dpx nabosignature poly
      a,←⊂'Orbital signature'dpx orbitsignature poly
      :If dim≥3
          t←'Cube meeting signature:' 'Row idx= No. cubes in meeting'
          t,←'Col idx= Dimension of meeting' 'Row,Col: Count of meetings'
          a,←⊂t dpy(⍪⍳1+(2*dim)⌊≢poly)(cubesignature realpoly)
      :Else
          t←'Cube meeting signatures:' 'Row idx= No. cubes in meeting'
          t,←'Col idx= Dimension of meeting' 'Row,Col: Count of meetings' 'Lifted and base'
          a,←⊂t dpy⊃,/(⊂⍪⍳1+(2*dim)⌊≢poly)(,cubesignature¨poly realpoly)
      :EndIf
     
      reportpanel.Text←dpz 2 5⍴a,'' '' '' '' ''
    ∇
    
 
  
:endClass



