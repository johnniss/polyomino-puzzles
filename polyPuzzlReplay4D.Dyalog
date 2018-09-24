:Class polyPuzzlReplay4D    ⍝ Replay earlier found solutions to puzzles in 4 dimensions, 8.apr 2018
   
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
                                                                                 
    ⍝ :include #.polyUtil   ⍝utilFns
    :include #.polyFns 

    ∇ new subform
      :Access Public     
      :Implements Constructor
     
      guisetup subform
     
      appsetup #.puzlsolindx   ⍝ ¯1+≢#.pdb.solutions    ⍝ 78   ⍝  58    ⍝'My4d'
    ∇
    
    ∇ guisetup subform;statusmat;i;rno;cno;ma;rowno;colno
     
      repform←subform makeformu(10 80 10)(3 94 3)                            ⍝  Define all forms and subforms
      replayform←repform.subforms[1;1]
     
      matrixsize←8
      solform←replayform makeformu(10 15 5 60 10)(1 98 1)
      shelve←solform.subforms[1;1]        ⍝ Shelve of pieces
      shelvepos←shelve makeformu(1 98 1)(3,(15⍴11 1),2)
     
      subshelve←solform.subforms[2;1]
      topline←solform.subforms[0;1]
     
      mainx←solform.subforms[3;1]
     ⍝ mains←mainx makeformu(1 98 1)(1 48 2 48 1)
⍝      main←mains.subforms[1;1 3]
     
      botline←solform.subforms[4;1]
      matrixsf←shelvepos.subforms[1;1+2×⍳matrixsize]
     
      GUInames
     
      :With Label1←topline.⎕NEW Label(⊂Caption' Replay 4D solution')                                 ⍝ labels buttons and combox
          FontObj←'ARIAL' 25 0 ⋄ Size←30 200 ⋄ Posn←##.Mm-0 100
      :EndWith
     
      fastbackward backward forward fastforward←{subshelve.⎕NEW Button(⊂Style Push)}¨⍳4
      :For but ix :InEach (fastbackward backward forward fastforward)(⍳4)
          but.FontObj←ARIAL 20 ⋄ but.Size←30 50 ⋄ but.Posn←(subshelve.Um)+ix⊃(5 ¯110)(5 ¯55)(5 0)(5 55)
          but.Caption←ix⊃('|←' '←' '→' '→|')
          but.Event←⊂Select'next&'(ix⊃¯8 ¯1 1 8)
      :EndFor
     
      bup bright bdown bleft←{botline.⎕NEW Button(⊂Style Push)}¨⍳4
      :For but ix :InEach (bup bright bdown bleft)(⍳4)
          but.Size←30 30 ⋄ but.Posn←(botline.Um)+ix⊃(5 ¯16)(5 16)(37 ¯16)(5 ¯48)
          but.FontObj←'APL385 Unicode' 15 ⋄ but.Caption←ix⊃('⍋' '>' '⍒' '<')
          but.Event←(MouseDown'turn&'ix)(MouseUp'stoprot&')
      :EndFor
     
      :With butn6←botline.⎕NEW Button(⊂Caption'R')
          Size←30 30 ⋄ Posn←##.Ur+5 ¯32
      :EndWith
      butn6.Event←(MouseDown'removelast')(MouseUp'mousenull&')
     
      :With butn7←botline.⎕NEW Button(⊂Caption'Rbox')
          Size←30 40 ⋄ Posn←##.Ul+5 0
      :EndWith
      butn7.Event←(MouseDown'dropbox')(MouseUp'mousenull&')
     
      :With butn8←botline.⎕NEW Button(⊂Caption'Reset')
          Size←30 40 ⋄ Posn←##.Ul+5 50
      :EndWith
      butn8.Event←(MouseDown'reset')(MouseUp'mousenull&')
     
      :For ssf ix :InEach matrixsf(⍳⍴matrixsf)                               ⍝ The piece shelve
          ssf.XRange←2.5×1 ¯1
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
     
    ∇
    
  
    
    ∇ appsetup puzl;order;solno
     
      passive active frozen←⍳3        ⍝ piece mode
      left right←1 2
      freezetime placement polyomino color←⍳4
     
      :If puzl≡'My4d'
          sol←#.mysol4D
          solno←1
          placements←sol.solutions[solno;]⊃¨sol.pieceplacements
          puzzlename←'My4D'
          collname←'All 5+2'
          color pvdid←((#.pdb.userCollections)withname collname).(color voldimid)
          placementserie←0,(⍪placements),(⍪↓pvdid),(⍪↓color)
      :ElseIf puzl≢⍬
          solution←puzl⊃#.pdb.solutions
          puzzlename←solution.name
          placementserie←(puzl⊃#.pdb.solutions).placementserie
          ⍝ ddx placementserie
      :EndIf
     
      pieces←{⎕NEW replaypiece4D ⍵}¨↓placementserie  ⍝  (placements vol dim globalid chiral farve)
     
      ⍝ pieces.freezetime←0,-2-/pieces.freezetime         ⍝ pairwise time dif. instead of absolute freeztime
      showrow←pieces             ⍝ the showrow is all the pieces
      piececount←≢showrow
     
      firstpiece←0
      ⍝ drawstop←0
      hittencells←0
      boxdim←solution.box   ⍝2 2 2 5    ⍝2 2 3 11   ⍝ solution.box
      freespace←,⍳boxdim
     
      0 next 0 
      
     ⍝ boxspace←freespace
     ⍝ boxframe←(,⍳boxdim+1)~boxspace
     ⍝ theboxes←main{⎕NEW box(⍺ ⍵)}¨⍳⊃boxdim
     ⍝ boxpieces←{⎕NEW replaypiece4D((,⊂↑boxframe)⍵)}¨theboxes          ⍝ the box as piece
     
     boxsetup solution

      boxsize←⊃×/boxdim
    ∇ 
    
      ∇ boxsetup puzl
     
      boxdim←puzl.box
      freespace←,⍳boxdim     
      boxspace←freespace
      boxframe←(,⍳boxdim+1)~boxspace 
      
      dimensionality←≢boxdim~1 
      ⍝ Label2.Caption←' ',(⍕dimensionality),'D'
      :If dimensionality≤3
          boxno←1
      :ElseIf dimensionality=4
          boxno←⊃boxdim
      :EndIf      

       :If boxno=1        
          mains←mainx makeformu(1 98 1)(1 98 1)
          main←mains.subforms[1;1]
      :ElseIf boxno=2
          mains←mainx makeformu(1 98 1)(1 48 2 48 1)
          main←mains.subforms[1;1 3]
      :ElseIf boxno=3
          mains←mainx makeformu(1 98 1)(1 32 1 32 1 32 1)
          main←mains.subforms[1;1 3 5]
      :EndIf
     
      theboxes←main{⎕NEW replaybox(⍺ ⍵)}¨⍳boxno  
      
      boxpieces←{⎕NEW replaypiece4D((,⊂↑boxframe)⍵)}¨theboxes 

      ⍝ thewholebox←#.⎕NEW #.polyominod((⌽↑boxframe)(3⍴¨150 100 50))            ⍝ ((⌽↑boxframe)(3⍴¨150 100 50))
     
     ⍝  boxpiece←⎕NEW replaypiece4D((,⊂↑boxframe)theboxes wholebox)          ⍝ the box as piece
      boxpieces.state←frozen
      ⍝ boxpiece.id←0
      ⍝ boxpiece.currentplacement←boxframe
      ⍝ pieces←(⊂boxpiece),pieces
    
    
      ⍝ thewholebox←⍬

    
   ⍝   0 next 0 

      ⍝ mainx←solform.subforms[3;1]
     
    ∇
    
  
     
⍝========================== callbacks =========================================  
  

    ∇ ssf selectpiece msg;ok;theselectedpiece     ⍝ a selectbutn was set
      :Hold 'Box' 'select'
          ssf no←ssf
          theselectedpiece←showrow[firstpiece+no]
          theactivepiece←theselectedpiece
          lastplacement←⍬
      :EndHold
      theselectedpiece.jumpintobox nofrozenpieces  ⍝intobox
      theboxes.drawit(⊂theselectedpiece)
      theactivepiece←⍬
      0 next 0
    ∇
    
    ∇ broadcast(frombox selpiece)
      :Access Public
     
      (theboxes~frombox).drawit(⊂selpiece)
    ∇
    
    ∇ dropbox   ⍝ Drop box platform  on all
      :Hold 'Box'
          theboxes.dropbox
          ⍝ thebox.draw main
      :EndHold
    ∇
    
    ∇ reset
     
      appsetup #.puzlsolindx    ⍝ 'My4d'
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
    
        
    ∇ dir turn msg  ⍝ Make thebox rotate
      :Hold 'stopit'
          rotstop←0
      :EndHold
      :Repeat
          :Hold 'Box'
              theboxes.turn dir
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
              theboxes.removelast                    ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
              ⍝ theboxes.draw main
              freespace∪←↓⊃lastfrozen.placement
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
           

    ∇ dir next msg   ⍝ Shift pieces left or right on the piece shelve
      :Access Public
     
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
    
   
    
    ∇ pstate selectstate dumy       ⍝ chage state in showrow
     
      showrow←unused
      piececount←≢showrow
      matrixsf.selector.Visible←pstate=passive       ⍝ Selector only visible on unused pieces
      0 next 0
    ∇
    
    ∇ res←unused  ⍝ return unused pieces ie. state=0  passive
      :Access Public
     
      res←(passive=pieces.state)/pieces
    ∇
    
    ∇ res←nounused  ⍝ return number of unused pieces ie. state=0  passive
      :Access Public
     
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
         

⍝========================== class box, replaypiece4D ======================================= 

    :class replaybox 
        :field Public thebox             ⍝ Unique id of the piece 
        :field Public main               ⍝ canves form
        :field Public c4
        :field Public filcol←100 100 100           
                  
        ∇ new(form coordinate4D)
          :Access Public     
          :Implements Constructor
         
         
          passive active frozen←⍳3        ⍝ piece mode
          left right←1 2
          freezetime placement polyomino color←⍳4
         
          boxdim←1↓##.boxdim    ⍝2 2 5   ⍝2 3 11
          c4←coordinate4D
          freespace←c4,¨,⍳boxdim
          boxspace←freespace
          boxframe←(,⍳boxdim+1)~⍳boxdim
          thebox←⎕NEW #.polyominod((⌽↑boxframe)(3⍴¨150 100 50))            ⍝ ((⌽↑boxframe)(3⍴¨150 100 50))
          lastplacement←⍬
          hittencells←0
         
          main←form
          main scaleit 6
         
          thebox.makepalette
          thebox.draw main
        ∇
           
        ∇ form scaleit scalefac
         
          form.XRange←scalefac×¯1 1
          form.(YRange←XRange×Aspect)
          form.Event←('MouseDown' 'shoot&')('MouseUp' 'mousenull&')
         
          difsize←|form.((-/¨YRange XRange)÷Size)                                       ⍝ Scalefactor
          min←form.(⌊/¨YRange XRange)
          size←form.Size
        ∇
    
      
        ∇ shoot msg;pos;yxpos;hotpiece;direction;affectedcell        ⍝ Make hotspot, Call back from mouse down
         
          pos←msg[2 3]
          mousebutn←4⊃msg
          yxpos←⊂min+difsize×pos              ⍝ Position in polygon coordinates  ⍝ yxpos←⊂(dif×pos÷size)+min
          :If mousebutn=left                    ⍝ Make new hotcell
              hitcell direction←⊂∘⌽¨thebox.markfacex yxpos   ⍝  the hitten polygon, and get the cellid
              :If hitcell≢⍬
                  affectedcell←hitcell+direction
                  :If (⊂c4,⊃affectedcell)∊boxspace     ⍝ placement←c4,⌽0 1↓↑boxspace∩↓theactivepiece.placement
                      thebox.paintyellow
                      thebox.draw main
                      hittencells←1
                      ⎕DL 0.5               ⍝ Let the yellow spot stand for a short moment
                      theselectedpiece←⊃((⊂⊂c4,⊃affectedcell)∊¨##.unused.placement)/##.unused   ⍝ ∘↓
                      theactivepiece←theselectedpiece
                      lastplacement←⍬
                      theselectedpiece.jumpintobox ##.nofrozenpieces   ⍝ fragment
                      drawit theselectedpiece
                      repaint               ⍝ Remove the yellow spot again
                      ##.broadcast ⎕THIS theselectedpiece
                      theactivepiece←⍬
                      0 ##.next 0
                  :EndIf
              :EndIf
          :EndIf
        ∇

    
        ∇ mousenull   ⍝ default on mouseup, preventing strange behaveor
         
        ∇
        
        ∇ turn dir
          :Access Public
         
          :Select dir
          :Case 0
              thebox.turndown
          :Case 1
              thebox.turnback
          :Case 2
              thebox.turnup
          :Case 3
              thebox.turn
          :EndSelect
          thebox.draw main
        ∇

    
        ∇ removeactive
         
          :If ⍬≢theactivepiece
              theactivepiece.jumpoutofbox                      ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
              thebox.removelast
              thebox.draw main
              theactivepiece←⍬
          :EndIf
        ∇
          
        ∇ removelast
          :Access Public 
         
          thebox.removelast
          thebox.draw main
        ∇
        
        ∇ dropbox   ⍝ Drop box platform
          :Access Public 
         
          ⍝:Hold 'Box'
          thebox.remove 0
          thebox.draw main
          ⍝:EndHold
        ∇

        ∇ repaint;starts;sizes;ids;fp;fpvolume   ⍝ remove yellow hotspots
         
          :If 0<hittencells
              thebox.repaintall
              thebox.draw main
              ##.pieces.hashotspot←0
              hittencells←0
          :EndIf
        ∇
    
        ∇ drawit theactivepiece;isold;isfrozen;dumy    ⍝ Function that draws the boxes
          :Access Public   
         
          ⍝:Hold 'Box'
          :If ⍬≢theactivepiece
             ⍝ :If ⍬≢lastplacement
⍝                  thebox.removelast
⍝              :EndIf
              placement←c4,⌽0 1↓↑boxspace∩theactivepiece.placement
              thebox.addnewwithcolor placement theactivepiece.pfc         ⍝ ((⌽↑c4⊃(placement[;0]))(pfc))
              lastplacement←placement
              thebox.draw main
          :EndIf
          ⍝:EndHold
        ∇
        
        ∇ drawx
          :Access Public   
         
          thebox.draw main
        ∇
     
    :endClass


    :class replaypiece4D                ⍝ class for  pieces during the game
        
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
        :field Public chiralind←0     ⍝ Chiral indicator 
        :field Public freezetime←0    ⍝ Time of freeze 
        
        :include #.polyFns      ⍝ Util

        ∇ new(pplacement ppolyd)  ⍝ For the box as piece
          :Access Public     
          :Implements Constructor
         
          placement←pplacement
          id←0
          pfc←ppolyd.filcol
          polyd←ppolyd    ⍝ {#.⎕NEW #.polyominod(⍵ ⍬ ⍬ ⍬ ⍬)}¨ppolyd             ⍝ A fresh copy of polyominod
         
          ⍝ volume←≢⊃placement
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
         
          :If dimension=4
              polyomino←⊃globalid pvd volume dimension
              chiralind←chirality polyomino              ⍝ #.polyFns.
          :Else
              chiralind←0
          :EndIf
          :If chiralind
              chirallabel←'LR'[¯0.5×¯1+4⊃(↑placement)adrdif polyomino]     ⍝ #.polyFns.
          :EndIf
         
          polyd←#.⎕NEW #.polyominod(volume dimension globalid farve)              ⍝ A fresh copy of polyo    minod
         
          passive active frozen←⍳3                                  ⍝ Categories of state
          state←passive
        ∇
                
        ∇ jumpintobox nofrozenpieces    ⍝ the active piece are thrown into the box at random
          :Access Public 
         
          id←1+nofrozenpieces
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
 
      
:EndClass  ⍝ polyPuzzlReplay
