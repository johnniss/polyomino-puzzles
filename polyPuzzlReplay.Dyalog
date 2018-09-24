:Class polyPuzzlReplay    ⍝ :Class testPuzzlReplay    ⍝ Replay earlier found solutions to puzzles, 8. apr 2018
   
    :Field Public pieces      
    :Field Public hotcells←⍬
    :Field Public pieceplacements
    :Field Public freespace                ⍝ the nonfrozen space
    :Field Public boxspace←⍬               ⍝ The space occupied of frozen pieces
    :Field Public frozenno←0
    :Field Public boxdim
    :Field Public puzzlename
    :Field Public theactivepiece←⍬ 
    :Field Public starttime←⍬            ⍝ game starttime
    :Field Public curdur←0               ⍝ Current durataion in seconds  
    :Field Public solfound←0             ⍝ A solution is found
                                                                                 
    :include #.polyFns     ⍝Util    ⍝ utilFns

    ∇ new subform
      :Access Public     
      :Implements Constructor
     
      guisetup subform
     
      appsetup 4    ⍝ 'My puzzl c5'
    ∇
    
    ∇ guisetup subform;statusmat;i;rno;cno;ma;rowno;colno
     
      repform←subform makeformu(10 80 10)(4 35 2 65 4)
      tableform←repform.subforms[1;1]
      replayform←repform.subforms[1;3]
     
      guisetup2 replayform
     
      ma←↑#.pdb.solutions.((+/1<box)((1<box)/box) piececount(3↑starttime)(2↑3↓starttime)(1000  60 ⊤duration))
      ma←⊖ma,1+⍳≢ma
      rowno colno←⍴ma
      glrowno←rowno
     
      :With Gridx←tableform.⎕NEW Grid(⊂CellHeights 21)  ⍝ Grid over polyomino database
          Values←ma
          FontObj←'ARIAL' 15
          Size←##.Size
          Posn←0 0
          CellWidths←20 50 30 70 40 40 35
          CellTypes←(rowno colno)⍴1
          ColLineTypes←colno⍴1
          ColTitles←'D' 'Box' 'Pcs' 'Date' 'Time' 'Dur' 'No'
          GridLineFCol←0
          GridLineWidth←1
          Input←''
          RowLineTypes←rowno⍴1
          RowTitles←⊖#.pdb.solutions.name
      :EndWith
      Gridx.Event←(CellDown'cellitdown')
    ∇
                               
     
    ∇ guisetup2 subform;statusmat;i;rno;cno;sz
      matrixsize←8
      solform←subform makeformu(10 15 5 60 10)(5 90 5)
      shelve←solform.subforms[1;1]        ⍝ Shelve of pieces
      shelvepos←shelve makeformu(1 98 1)(3,(15⍴11 1),2)
      subshelve←solform.subforms[2;1]
      topline←solform.subforms[0;1]
      main←solform.subforms[3;1]
      botline←solform.subforms[4;1]
      matrixsf←shelvepos.subforms[1;1+2×⍳matrixsize]
     
      GUInames
     
      :With Label1←topline.⎕NEW Label(⊂Caption' Replay solution')
          FontObj←'ARIAL' 25 0 ⋄ Size←30 200 ⋄ Posn←40 250
      :EndWith
     
      fastbackward backward forward fastforward←{subshelve.⎕NEW Button(⊂Style Push)}¨⍳4
      :For but ix :InEach (fastbackward backward forward fastforward)(⍳4)
          but.FontObj←ARIAL 20 ⋄ but.Size←30 50 ⋄ but.Posn←(subshelve.Um)+ix⊃(5 ¯110)(5 ¯55)(5 0)(5 55)
          but.Caption←ix⊃('|←' '←' '→' '→|')
          but.Event←⊂Select'next&'(ix⊃¯8 ¯1 1 8)
      :EndFor
     
      bup bright bdown bleft←{botline.⎕NEW Button(⊂Style Push)}¨⍳4
      :For but ix :InEach (bup bright bdown bleft)(⍳4)
          but.Size←30 30 ⋄ but.Posn←(botline.Um)+ix⊃(5 0)(5 32)(37 0)(5 ¯32)
          but.FontObj←'APL385 Unicode' 15 ⋄ but.Caption←ix⊃('⍋' '>' '⍒' '<')
          but.Event←(MouseDown'turn&'ix)(MouseUp'stoprot&')
      :EndFor
     
      :With butn6←botline.⎕NEW Button(⊂Caption'R')
          Size←30 30 ⋄ Posn←##.Ur+5 ¯32
      :EndWith
      butn6.Event←(MouseDown'removelast')(MouseUp'mousenull&')
     
      :For ssf ix :InEach matrixsf(⍳⍴matrixsf)                               ⍝ The piece shelve
          ssf.XRange←2×1 ¯1
          ssf.(YRange←XRange×-Aspect)
     
          ssf.FontObj←'ARIAL' 15
          ssf.Event←(MouseEnter'rotate&'ssf)(MouseLeave'stoprot&')(MouseDown'rotate&'ssf)
     
          ssf.selector←ssf.⎕NEW Button(⊂Style Radio)
          ssf.selector.Size←20 20 ⋄ ssf.selector.Posn←0 0 ⋄ ssf.selector.State←0
          ssf.selector.Event←⊂Select'selectpiece&'(ssf ix)
     
          ssf.count←ssf.⎕NEW Label(⊂FieldType'Numeric')
          ssf.count.Size←15 35 ⋄ ssf.count.(Posn←##.Ur-(0 40)) ⋄ ssf.count.Value←12345
     
          ssf.chirallab←ssf.⎕NEW Label(⊂FieldType'Char')
          ssf.chirallab.(Size Posn)←(15 15)((¯15+⊃ssf.Size)0) ⋄ ssf.chirallab.Value←'L+R'
      :EndFor
     
      scalefac←7
      main.XRange←scalefac×¯1 1
      main.(YRange←XRange×Aspect)
      main.Event←(MouseDown'shoot&')(MouseUp'mousenull&')
     
      difsize←|main.((-/¨YRange XRange)÷Size)                                       ⍝ Scalefactor
      min←main.(⌊/¨YRange XRange)
      size←main.Size
    ∇
    
    ∇ appsetup puzl;order
     
      passive active frozen←⍳3        ⍝ piece mode
      left right←1 2
      freezetime placement polyomino color←⍳4
     
      :If puzl≢⍬
          solution←puzl⊃#.pdb.solutions
          puzzlename←solution.name
          #.puzlsolindx←puzl
          placementserie←(puzl⊃#.pdb.solutions).placementserie
      :EndIf
     
      pieces←{⎕NEW replaypiece ⍵}¨↓placementserie  ⍝  (placements vol dim globalid chiral farve)
     
      pieces.freezetime←0,-2-/pieces.freezetime         ⍝ pairwise time dif. instead of absolute freeztime
      showrow←pieces             ⍝ the showrow is all the pieces
      piececount←≢showrow
     
      firstpiece←0
      drawstop←0
      hittencells←0
      boxdim←solution.box
      freespace←,⍳boxdim
     
      0 next 0
      boxspace←freespace
      boxframe←(,⍳boxdim+1)~boxspace
      thebox←#.⎕NEW #.polyominod((⌽↑boxframe)(3⍴¨150 100 50))            ⍝ ((⌽↑boxframe)(3⍴¨150 100 50))
     
      boxpiece←⎕NEW replaypiece((,⊂↑boxframe)thebox)          ⍝ the box as piece
      boxpiece.placement←boxframe
      pieces←(⊂boxpiece),pieces
     
      boxsize←⊃×/boxdim
      thebox.makepalette
      thebox.draw main
    ∇
    
  
     
⍝========================== callbacks =========================================  
   
   
    ∇ cellitdown msg;puzlindx           ⍝ Callback , chosen puzzle line in grid
     
      puzlindx←msg[6]
      :If puzlindx≥0
          appsetup glrowno-puzlindx+1
      :EndIf
    ∇
     
    ∇ shoot msg;pos;yxpos;hotpiece;direction;affectedcell        ⍝ Make hotspot, Call back from mouse down
      pos←msg[2 3]
      mousebutn←4⊃msg
      yxpos←⊂min+difsize×pos              ⍝ Position in polygon coordinates  ⍝ yxpos←⊂(dif×pos÷size)+min
      :If mousebutn=left                    ⍝ Make new hotcell
          hitcell direction←⊂∘⌽¨thebox.markfacex yxpos   ⍝  the hitten polygon, and get the cellid
          :If hitcell≢⍬
              affectedcell←hitcell+direction
              :If affectedcell∊boxspace
                  thebox.paintyellow
                  thebox.draw main
                  frozenpieces.contains hitcell
                  hittencells+←1
                  ⎕DL 0.5               ⍝ Let the yellow spot stand for a short moment
                  theselectedpiece←⊃((⊂affectedcell)∊¨unused.placement)/unused
                  theactivepiece←theselectedpiece
                  lastplacement←⍬
                  theselectedpiece.jumpintobox nofrozenpieces
                  drawit
                  repaint               ⍝ Remove the yellow spot again
                  theactivepiece←⍬
                  0 next 0
              :EndIf
          :EndIf
      :EndIf
    ∇
 

    ∇ ssf selectpiece msg;ok;theselectedpiece     ⍝ a selectbutn was set
      :Hold 'Box' 'select'
          ssf no←ssf
          theselectedpiece←showrow[firstpiece+no]
          theactivepiece←theselectedpiece
          lastplacement←⍬
      :EndHold
      theselectedpiece.jumpintobox nofrozenpieces  ⍝intobox
      drawit
      theactivepiece←⍬
      0 next 0
    ∇
     
    ∇ ssf rotate msg                        ⍝ Make a passive piece rotate
      rotstop←1
      :Hold 'stopit'
          rotstop←0
          :Repeat
              ssf.poly.turn                               ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
              ssf.poly.draw ssf
              ⎕DL 0.01
          :Until rotstop=1
      :Else
      ⍝leave dont bother
      :EndHold
    ∇
    
        
    ∇ dir turn msg    ⍝ Make thebox rotate
      :Hold 'stopit'
          rotstop←0
      :EndHold
      :Repeat
          :Hold 'Box'
              :Select dir
              :Case 0
                  thebox.turndown                            ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
              :Case 1
                  thebox.turnback
              :Case 2
                  thebox.turnup
              :Case 3
                  thebox.turn
              :EndSelect
              thebox.draw main
              ⎕DL 0.05
          :EndHold
      :Until rotstop=1
    ∇

     
    ∇ removelast;lastfrozen                         ⍝ Remove last frozen piece
      :Hold 'Box'
          :If 1<≢frozenpieces
              lastfrozen←¯1↑frozenpieces
              :If lastfrozen.hashotspot
                  repaint
              :EndIf
              lastfrozen.state←passive
              thebox.removelast                    ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
              thebox.draw main
              freespace∪←⊃lastfrozen.placement
          :EndIf
          0 selectstate 0
      :Else               ⍝  attempt to prevent prell behaveor on R button
      :EndHold
    ∇

    ∇ stoprot     ⍝ Stop rotation
      rotstop←1
    ∇
    
    ∇ mousenull   ⍝ default on mouseup, preventing strange behaveor
     
    ∇
    
    ∇ stopdraw    ⍝ Stop drawing
      drawstop←1
    ∇
           

    ∇ dir next msg   ⍝ Shift pieces left or right on the piece shelve
     
      showrow←unused                 ⍝ The showrow is redused to the unused/passive pieces
      piececount←nounused
      firstpiece+←dir
      firstpiece⌈←0
      firstpiece⌊←¯1+piececount
      lastpiece←firstpiece+matrixsize-1
      lastpiece⌊←¯1+piececount
      pno←1+lastpiece-firstpiece
      :If piececount>0
          showset←showrow[firstpiece+⍳pno]
      :End
      matrixsf.poly←matrixsize↑showset.polyd,matrixsize⍴⍬
      matrixsf.count.Value←matrixsize↑showset.freezetime,matrixsize⍴0
      matrixsf.chirallab.Value←matrixsize↑showset.chirallabel,matrixsize⍴⊂' '
      matrixsf.Visible←pno>⍳matrixsize
      matrixsf.selector.State←0
      :If piececount>0
          {⍵.poly.draw ⍵}¨pno↑matrixsf                      ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
      :Else
          matrixsf.Visible←0
      :EndIf
    ∇

  ⍝================================ main utils =====================================
    
    ∇ drawit;isold;isfrozen;dumy    ⍝ Started task that draws box
     
      :Access Public   
      :If ~drawstop
          :Hold 'Box'
              :If ⍬≢theactivepiece
                  :If ⍬≢lastplacement
                      thebox.removelast
                  :EndIf
                  thebox.addnewwithcolor theactivepiece.((⌽↑placement)(pfc))
                  lastplacement←theactivepiece.placement
                  thebox.draw main                                                        ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
              :EndIf
          :EndHold
      :EndIf
    ∇
    
    ∇ pstate selectstate dumy       ⍝ chage state in showrow
     
      showrow←unused
      piececount←≢showrow
      matrixsf.selector.Visible←pstate=passive       ⍝ Selector only visible on unused pieces
      0 next 0
    ∇
    
    
    ∇ removeactive
     
      :If ⍬≢theactivepiece
          theactivepiece.jumpoutofbox                      ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
          thebox.removelast
          thebox.draw main
          theactivepiece←⍬
      :EndIf
    ∇
    
    ∇ repaint;starts;sizes;ids;fp   ⍝ remove yellow hotspots
     
      :If 0<hittencells
          thebox.repaintall
          thebox.draw main
          frozenpieces.hashotspot←0
          hotcells←⍬
          hittencells←0
      :EndIf
    ∇
      
    
    ∇ res←unused  ⍝ return unused pieces ie. state=0  passive
      res←(passive=pieces.state)/pieces
    ∇
    
    ∇ res←nounused  ⍝ return number of unused pieces ie. state=0  passive
      res←+/passive=pieces.state
    ∇
    
    ∇ res←frozenpieces;fp  ⍝ frozen pieces ie. state=2  frozen
      :Access Public
     
      fp←(frozen=pieces.state)/pieces
      res←fp[⍋fp.id]
    ∇
    
    ∇ res←nofrozenpieces  ⍝ Number of frozen pieces ie. state=2  frozen
      :Access Public
      res←¯1++/frozen=pieces.state        ⍝ the box as frozen piece dosent count
    ∇
    

⍝========================== class piece def =======================================

    :class replaypiece                ⍝ class for  pieces during the game
        
        :field Public id              ⍝ Unique id of the piece
        :Field Public placement       ⍝ Actual possible placements in the box   
        :Field Public polyd           ⍝ Polyominod displayobject
        :field Public volume          ⍝ Polyomino volume 
        :field Public dimension       ⍝ Polyomino dimension 
        :field Public globalid        ⍝ Polyomino globalid 
        :Field Public state           ⍝ 0=passive, 1=active, , 3=frozen. 
        :field Public hashotspot←0    ⍝ If the piece has a hotspot
        :field Public pfc             ⍝ the color  
        :field Public chirallabel←' ' ⍝ Chiral label: blank, L, R or L+R 
        :field Public chiral←0        ⍝ Chiral indicator 
        :field Public freezetime←0    ⍝ Time of freeze 
        
        :include #.polyFns      ⍝Util

        ∇ new(pplacement ppolyd)  ⍝ For the box as piece
          :Access Public     
          :Implements Constructor
         
          placement←pplacement
          id←0
          pfc←ppolyd.filcol
          polyd←ppolyd    ⍝ {#.⎕NEW #.polyominod(⍵ ⍬ ⍬ ⍬ ⍬)}¨ppolyd             ⍝ A fresh copy of polyominod
         
          volume←≢polyd.polyomino
          passive active frozen←⍳3                                  ⍝ Categories of state
          state←frozen
        ∇
        
        ∇ new2(ftime pplacement voldimno farve)  ⍝ The normal pieces
          :Access Public     
          :Implements Constructor
         
          freezetime←ftime
          placement←pplacement
         
          pfc←farve
          volume dimension globalid←voldimno
         
          :If dimension=3
              polyomino←⊃globalid #.polyFns.pvd volume dimension
              chiral←chirality polyomino       ⍝ #.polyFns.chiral
          :Else
              chiral←0
          :EndIf
          :If chiral
              chirallabel←'LR'[¯0.5×¯1+4⊃(↑placement)adrdif polyomino]   ⍝ #.polyFns.
          :EndIf
         
          polyd←#.⎕NEW #.polyominod(volume dimension globalid farve)              ⍝ A fresh copy of polyo    minod
         
          passive active frozen←⍳3                                  ⍝ Categories of state
          state←passive
        ∇
                
        ∇ jumpintobox nofrozenpieces   ⍝ the active piece are thrown into the box at random
          :Access Public 
         
          id←1+##.nofrozenpieces
          state←frozen
        ∇
                             
        ∇ contains hotspot
          :Access Public 
         
          :If ~hashotspot
              hashotspot←(⊂hotspot)∊placement
          :EndIf
        ∇
           
        ∇ jumpoutofbox
          :Access Public 
         
          state←passive
          hashotspot←0
        ∇
                                 
        ∇ res←isfrozen
          :Access Public
         
          res←state=frozen
        ∇
  
    :endclass  ⍝ replayPiece 

    :endclass  
