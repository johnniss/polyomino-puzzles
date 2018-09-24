:Class polyPuzzlMan4d     ⍝ Solves a specified puzzle and monitors the process xx,  14/10 17

    :Field Public pieces
    :Field Public hotcells←⍬
    :Field Public pieceplacements
    :Field Public freespace                ⍝ the nonfrozen space cc
    :Field Public boxspace←⍬               ⍝ The space occupied of frozen pieces
    :Field Public frozenno←0
    :Field Public boxdim
    :Field Public puzzlename
    :Field Public theactivepiece←⍬
    :Field Public starttime←⍬            ⍝ game starttime
    :Field Public curdur←0               ⍝ Current durataion in seconds
    :Field Public solfound←0             ⍝ A solution is found
    :Field Public showstate←0            ⍝ state of piece shelve
    :Field Public hotcount ←0            ⍝ count of hot placements

    :include #.polyFns

    ∇ new subform
      :Access Public
      :Implements Constructor
     
      guisetup subform
      appsetup ⍬
    ∇


    ∇ guisetup subform;statusmat;i;rno;cno;sz
     
      matrixsize←8
      solform←subform makeformu(10 15 5 60 10)(5 90 5)
      shelve←solform.subforms[1;1]        ⍝ Shelve of pieces
      shelvepos←shelve makeformu(1 98 1)(3,(15⍴11 1),2)
      subshelve←solform.subforms[2;1]
      topline←solform.subforms[0;1]
      botline←solform.subforms[4;1]
      matrixsf←shelvepos.subforms[1;1+2×⍳matrixsize]
     
      GUInames
     
      :With Label1←topline.⎕NEW Label(⊂Caption'   Manually solving')
          FontObj←'ARIAL' 25 0 ⋄ Size←30 200 ⋄ Posn←40 450
      :EndWith
     
      fastbackward backward forward fastforward←{subshelve.⎕NEW Button(⊂Style Push)}¨⍳4
      :For but ix :InEach (fastbackward backward forward fastforward)(⍳4)
          but.FontObj←ARIAL 20 ⋄ but.Size←30 50 ⋄ but.Posn←5(435+ix×55)
          but.Caption←ix⊃('|←' '←' '→' '→|')
          but.Event←⊂Select'next&'(ix⊃¯8 ¯1 1 8)
      :EndFor
     
      :With butn0b←botline.⎕NEW Button(⊂Caption'No')
          FontObj←'APL385 Unicode' 15 ⋄ Size←32 32 ⋄ Posn←5 135 ⋄ Visible←0
      :EndWith
      butn0b.Event←(MouseDown'gamenormal&')(MouseUp'mousenull&')
     
      :With Label2←topline.⎕NEW Label(⊂Caption'Dim')
          FontObj←'ARIAL' 18 ⋄ Size←30 30 ⋄ Posn←40 270
      :EndWith
     
     
      ⍝ SetRotationButns
      bup bright bdown bleft←{botline.⎕NEW Button(⊂Style Push)}¨⍳4
      :For but ix :InEach (bup bright bdown bleft)(⍳4)
          but.Size←30 30 ⋄ but.Posn←(botline.Um)+ix⊃(5 ¯16)(5 16)(37 ¯16)(5 ¯48)
          but.FontObj←'APL385 Unicode' 15 ⋄ but.Caption←ix⊃('⍋' '>' '⍒' '<')
          but.Event←(MouseDown'turn&'ix)(MouseUp'stoprot&')
      :EndFor
     
      zoom←botline.⎕NEW Button(⊂Style Push)
      zoom.FontObj←'ARIAL' 25 ⋄ zoom.Size←30 30 ⋄ zoom.Posn←botline.Um+5 ¯90 ⋄ zoom.Caption←'Zz'
      zoom.Event←(MouseDown'zoominout&')(MouseUp'zoomstop&')
     
      :With butn4←botline.⎕NEW Button(⊂Caption'?')
          Size←32 32 ⋄ Posn←5 640 ⍝ ⋄ BCol←150 0 0
      :EndWith
      butn4.Event←(MouseDown'possible' 60)(MouseUp'mousenull&') 
     
      :With butn5←botline.⎕NEW'Circle'(⊂'Points'(20 690))
          Radius←10 ⋄ FillCol←200 200 200 ⋄ FStyle←0
      :EndWith
     
      :With butn6←botline.⎕NEW Button(⊂Caption'R')
          Size←32 32 ⋄ Posn←5 720
      :EndWith
      butn6.Event←(MouseDown'removelast')(MouseUp'mousenull&')
     
      :With butn7←botline.⎕NEW Button(⊂Caption'Random')
          FontObj←'ARIAL' 15 ⋄ Size←32 50 ⋄ Posn←5 50
      :EndWith
      butn7.Event←(MouseDown'random&')(MouseUp'mousenull&')
     
     
      :With durlab←botline.⎕NEW Label(⊂Caption'Dur: 0:00')            ⍝ Scores duration
          FontObj←'ARIAL' 16 0 ⋄ Size←20 80 ⋄ Posn←5 900
      :EndWith
     
      :With lamplab←botline.⎕NEW Label(⊂Caption'Lamp: 0 / 0')            ⍝ Scores lamp of red/green
          FontObj←'ARIAL' 16 0 ⋄ Size←20 80 ⋄ Posn←27 900
      :EndWith
     
      :With efflab←botline.⎕NEW Label(⊂Caption'Error free')            ⍝ Scores error free freezing
          FontObj←'ARIAL' 16 0 ⋄ Size←20 80 ⋄ Posn←49 900
      :EndWith
     
      puzlCombo←topline.⎕NEW Combo((VScroll ¯1)(Style'Drop'))
      :With puzlCombo
          FontObj←'ARIAL' 20 ⋄ Size←35 200 ⋄ Posn←40 10
          Items←#.pdb.puzzleCollection.name
      :EndWith
      puzlCombo.Event←Select'selectpuzzle&'
     
      cb←⍬
      subshelve.FontObj←'ARIAL' 20
      :For i :In ⍳4                                                        ⍝ radio but. unused active frozen
          cb,←subshelve.⎕NEW Button(⊂Caption'Unused')
          cb[i].Size←30 75 ⋄ cb[i].Posn←5(i×77) ⋄ cb[i].Style←'Radio'
          cb[i].Event←Select'selectstate&'i
      :EndFor
      cb[1 2 3].Caption←'Active' 'Frozen' 'Hot'
      cb.State←1 0 0 0
     
      :With labeluf←subshelve.⎕NEW Label(⊂Caption'unused/frozen')            ⍝ Score unfrozen / frozen
          FontObj←'ARIAL' 25 0 ⋄ Size←30 200 ⋄ Posn←5 850
      :EndWith
     
      :For ssf ix :InEach matrixsf(⍳⍴matrixsf)                               ⍝ The piece shelve
          ssf.XRange←2×1 ¯1
          ssf.(YRange←XRange×-Aspect)
          ssf.FontObj←'ARIAL' 15
          ssf.Event←(MouseEnter'rotate&'ssf)(MouseLeave'stoprot&')(MouseDown'rotate&'ssf)
          ssf.selector←ssf.⎕NEW Button(⊂Style Radio)
          ssf.selector.Size←20 20 ⋄ ssf.selector.Posn←0 0 ⋄ ssf.selector.State←0
          ssf.selector.Event←⊂Select'selectpiece&'(ssf ix)
          ssf.count←ssf.⎕NEW Label(⊂FieldType'Numeric')
          ssf.count.Size←15 35 ⋄ ssf.count.Posn←0 80 ⋄ ssf.count.Value←12345
          ssf.chirallab←ssf.⎕NEW Label(⊂FieldType'Char')
          ssf.chirallab.(Size Posn)←(15 25)((¯15+⊃ssf.Size)0) ⋄ ssf.chirallab.Value←'L+R'
      :EndFor
     
    ∇ ⍝ end GUIsetup     

    ∇ appsetup puzl
     
      passive active frozen←⍳3        ⍝ piece mode
      left right←1 2
      normal review←1 2               ⍝ Game mode
     
      puzlsetup ⍬
    ∇

    ∇ puzlsetup puzl;respuzl
     
      :If puzl≡⍬
          puzzlename←3⊃'Pento2225' 'Pento3335' 'My4D' 'My puzzl c5'       ⍝ default puzzle
      :Else
          puzzlename←puzl.name
      :EndIf
      ix←#.pdb.puzzleCollection.name⍳⊂puzzlename
      respuzl←ix⊃#.pdb.puzzleCollection                           ⍝ The chosen default puzl
     
      hittencells←0
      setlamp'Gray'
      redlamp←greenlamp←0
      errorfree←firsterror←0
      solfound←0
     
      piecesetup respuzl
      boxsetup respuzl
    ∇

    ∇ piecesetup puzl
     
      allpieces←puzl.pieces                                       ⍝ Pieces from puzl definition
      pmultipliers←allpieces.count
     
      cclrxx←{⍝ Preparing for reducing chiral pieces placements for lefts and rights
          chiral count lefts rights←⍵
          ~chiral:count⍴'N'                                   ⍝ Neutral
          ∧/0 0<lefts rights:⊃,/lefts rights⍴¨'LR'            ⍝ Placements should split
          0<lefts:lefts⍴'V'                                   ⍝ Left only
          0<rights:rights⍴'H'                                 ⍝ right only
          count⍴'B'                                           ⍝ Piece can be both
      }
     
      cclr←⊃,/cclrxx¨allpieces.(chiral count lefts rights)
     
      allpieces←pmultipliers/allpieces                        ⍝ reduce for null-pieces
      pieces←{⎕NEW solvepiece ⍵}¨allpieces.(placements vol dim globalid chiral farve)        ⍝ allpolyds.filcol
     
      pieces{⍺.chiraladjust ⍵}¨cclr                           ⍝ Executing chiral split
     
      order←⍋unused.countplacements                           ⍝ ids←(unused.id)[order]
      showrow←unused[order]
      piececount←≢showrow
      firstpiece←0
      labeluf.Caption←'No of pieces: ',(⍕≢pieces)
    ∇

    ∇ boxsetup puzl
     
      boxdim←puzl.boxdim
      freespace←,⍳boxdim
     
      boxspace←freespace
      boxframe←(,⍳boxdim+1)~boxspace
      thewholebox←#.⎕NEW #.polyominod((⌽↑boxframe)(3⍴¨150 100 50))            ⍝ ((⌽↑boxframe)(3⍴¨150 100 50))
     
      boxpiece←⎕NEW solvepiece((,⊂↑boxframe)thewholebox)          ⍝ the box as piece
      boxpiece.state←frozen
      boxpiece.id←0
      boxpiece.currentplacement←boxframe
      pieces←(⊂boxpiece),pieces
      thewholebox←⍬
     
      dimensionality←≢boxdim~1
      Label2.Caption←' ',(⍕dimensionality),'D'
     
      :If dimensionality≤3
          boxno←1
      :ElseIf dimensionality=4
          boxno←⊃boxdim
      :EndIf
     
      0 next 0
     
      mainx←solform.subforms[3;1]
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
     
      theboxes←main{⎕NEW solvebox(⍺ boxdim ⍵)}¨⍳boxno
    ∇


    :section Callbacks main

    ∇ ssf selectpiece msg;ok;theselectedpiece     ⍝ a selectbutn was set
      :Hold 'Box' 'select'
          ssf no←ssf
          theselectedpiece←showrow[firstpiece+no]
          :If theactivepiece≢theselectedpiece
              :If theactivepiece≢⍬
                  theactivepiece.jumpoutofbox                      ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
                  theboxes.removelast
                  setlamp'Gray'
                  theactivepiece←⍬
                  repaint
              :EndIf
              theactivepiece←theselectedpiece
              lastplacement←⍬
          :Else
              :Return
          :EndIf
      :Else
          :Return
      :EndHold
      :If starttime≡⍬                      ⍝ The game starts
          starttime←dursec 0
      :EndIf
      0 next 0
      theselectedpiece.jumpintobox
    ∇  

    ∇ random;pi            ⍝ some pieces chosen randomly
      :For i :In ⍳⌈(nounused)÷5
          pi←(#.?)nounused     ⍝ random piece
          theactivepiece←unused[pi]
          lastplacement←⍬
          theactivepiece.jumprandom       ⍝ jump to a random position in the box
      :EndFor
    ∇

    ∇ selectpuzzle;indx;puzl    ⍝ Select puzzle
      indx←⊃puzlCombo.(SelItems/⍳⍴SelItems)
      puzl←indx⊃#.pdb.puzzleCollection
      puzzlename←puzl.name
      indx←#.pdb.boxDims.name⍳⊂puzl.boxname
      boxvol←#.pdb.boxDims[indx].volume
      starttime←⍬
      puzlsetup puzl
    ∇

    ∇ dropbox   ⍝ Drop box platform
      :Hold 'Box'
          thebox.remove 0
          thebox.draw main
      :EndHold
    ∇

    ∇ ssf rotate msg                        ⍝ Make a passive piece rotate
      rotstop←1
      :Hold 'stoprotman'
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

    ∇ zoominout msg
      leftright←4⊃msg
      theboxes.zoominout leftright
    ∇

    ∇ zoomstop msg
    ∇

    ∇ pstate selectstate msg       ⍝ chage state in showrow
      :Access Public
      
      cb.State←0
      cb[pstate].State←1
      firstpiece←0
      showstate←pstate
      :Select pstate
      :Case frozen
          showrow←⌽1↓frozenpieces
      :Case active
          showrow←theactivepiece
      :Case passive
          showrow←unused
          :If 0<≢showrow
              order←⍋showrow.countplacements
              showrow←showrow[order]
              :If 0=showrow[0].countplacements           ⍝ a piece has become unplaceable
                  setlamp'Red'
              :EndIf
          :EndIf
      :Else
          :If 0<≢hotcells
              hotcount←unused.counthotplacements ⊂hotcells[0]
              showrow←(hotcount>0)/unused
              hotcount←(hotcount>0)/hotcount
              order←⍋hotcount
              showrow←showrow[order]
              hotcount←hotcount[order]
          :EndIf
      :EndSelect
      piececount←≢showrow
      matrixsf.selector.Visible←pstate∊passive 3       ⍝ Selector only visible on unused pieces
      0 next 0
    ∇

    ∇ removelast;lastfrozen                         ⍝ Remove last frozen or active piece
     
      :Hold 'Box'
          :If ⍬≢theactivepiece
            ⍝  removeactive
              theactivepiece.jumpoutofbox                      ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
              theboxes.removelast
              setlamp'Gray'
              theactivepiece←⍬
              repaint
          :ElseIf 1<≢frozenpieces
              lastfrozen←¯1↑frozenpieces
              :If lastfrozen.hashotspot
                  repaint
              :EndIf
              lastfrozen.state←passive
              theboxes.removelast
              freespace∪←⊃lastfrozen.currentplacement
              :If lampcolor≡'Red'
                  lastfrozen.removeimpossibleplacement nofrozenpieces
              :EndIf
              unused.newplacements nofrozenpieces
              ⍝ unused.newplacements
          :EndIf
          0 selectstate 0
          setlamp'Gray'
          scoreboard
      :Else               ⍝  attempt to prevent prell behaveor on R button
      :EndHold
    ∇

    ∇ stoprot     ⍝ Stop rotation
      rotstop←1
    ∇

    ∇ mousenull   ⍝ default on mouseup, preventing strange behaveor
     
    ∇

    ∇ timeoutlim possible msg;i;res       ⍝ test if there exist a solution from this point on.
      :hold 'timer'  
      setlamp'Orange'
      :If 0<nounused 
          foundsol←0 
          :if timeoutlim>10
            foundsol←0
            timerticks& timeoutlim 
          :endif
          res←⎕NEW polySolve(boxdim nounused(unused.placements)freespace timeoutlim)
          foundsol←1
          :If res.timeout
              setlamp'Black'
          :ElseIf res.result
              setlamp'Green'
          :Else
              setlamp'Red'
          :EndIf
          scoreboard 
          ⍝ butn4.Caption←'?'
      :Else
          setlamp'Gray'
      :EndIf  
     :else
       ⎕←'else hold'
     :endhold
    ∇

    ∇ dir next msg   ⍝ Shift pieces left or right on the piece shelve
     
      firstpiece+←dir
      firstpiece⌈←0
      firstpiece⌊←¯1+piececount
      lastpiece←firstpiece+7
      lastpiece⌊←¯1+piececount
      pno←1+lastpiece-firstpiece
      :If piececount>0
          showset←showrow[firstpiece+⍳pno]
      :End
      matrixsf.poly←8↑showset.polyd,7⍴⍬
      :If showstate=3  ⍝ hot hints
          matrixsf.count.Value←8↑hotcount[firstpiece+⍳pno],8⍴0
      :Else
          matrixsf.count.Value←8↑showset.countplacements,8⍴0
      :EndIf
      matrixsf.chirallab.Value←8↑showset.chirallabel,8⍴⊂' '
      matrixsf.Visible←pno>⍳8
      matrixsf.selector.State←0
      :If piececount>0
          {⍵.poly.draw ⍵}¨pno↑matrixsf                      ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
      :Else
          matrixsf.Visible←0
      :EndIf
    ∇

    :endsection  Main Callbacks


    :section utils main  ⍝================================ main utils =====================================

    ∇ drawit;curpl;color;isold;isfrozen;dumy    ⍝ Started task that draws box
      :Access Public
     
      :Hold 'Box'
          :If ⍬≢theactivepiece
          :AndIf 0<≢theactivepiece.currentplacement
          :AndIf lastplacement≢theactivepiece.currentplacement
              :If ⍬≢lastplacement
                  theboxes.removelastx
              :EndIf
              theboxes.drawit⊂theactivepiece.(currentplacement pfc)           ⍝ )curpl color)   ⍝ ⊂theactivepiece
              lastplacement←theactivepiece.currentplacement
          :EndIf
      :EndHold
    ∇
    
     ∇ timerticks seconds; s   ⍝ countdown timer when sercing for solution
     ⍝ :hold 'timer'
       :for s :in ⌽⍳seconds
        butn4.Caption←⍕s
        :if foundsol 
          :leave
        :else 
          ⎕DL 1
        :endif
       :endfor
       butn4.Caption←'?'
     ⍝:else
     ⍝:endhold
     ∇ 


    ∇ freeze curplac              ⍝ distribute spacereduction to unused pieces cccc
      :Access Public
     
      drawit
      :If 0<nounused
          unused.reduct⊂curplac
      :EndIf
      0 selectstate 0
      freespace~←curplac
      theactivepiece←lastplacement←hotcells←⍬
      repaint
      5 possible 0
      scoreboard
    ∇

    ∇ scoreboard;ef;sol            ⍝ updates the scorebord labels
      labeluf.Caption←'Rem: ',(⍕nounused),' Froz: ',⍕nofrozenpieces
      :If starttime≢⍬
          curdur←⌊dursec starttime
          durlab.Caption←'Dur: ',⍕24 60 60⊤curdur
      :EndIf
      :If 0=redlamp
          errorfree←nofrozenpieces
      :EndIf
      lamplab.Caption←'R/G : ',(⍕redlamp),' / ',⍕greenlamp
      :If 0=firsterror
          efflab.Caption←'Eff : ',⍕errorfree
      :ElseIf 0<firsterror
          efflab.Caption←'Eff : ',⍕errorfree,' / ',⍕¯1+≢pieces
          firsterror←¯1     ⍝ no more updates
      :EndIf
      :If 0=nounused   ⍝ A solution has been found
          solfound←1
          efflab.Caption←'Eff : ',⍕errorfree,' / ',⍕¯1+≢pieces
      :EndIf
    ∇

    ∇ fanfare;sol   ⍝ when all is done and a solution found
      :Access Public
     
      ⍝ :If gamemode=normal
      sol←⎕NEW #.utilSolution(⎕THIS)        ⍝ Store solution
      #.pdb.solutions,←sol
     
      butn0b.Visible←1       ⍝ make gamemode choicebut visible  butn0a
     
      ⎕←'****** Congratulations ******'starttime','curdur
      theboxes.removebox
      boxsize←0
      rotstop←0
      :Repeat
          :Hold 'Box'
              theboxes.turn 0                           ⍝⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
              theboxes.turn 3
                  ⍝ theboxes.draw main
          :EndHold
          ⎕DL 0.1
      :Until rotstop=1
      gamemode←review
      ⍝ :EndIf
      ⍝ gamereplay
    ∇

    ∇ repaint;starts;sizes;ids;fp   ⍝ remove yellow hotspots
     
      theboxes.repaint  ⍝all
      frozenpieces.hashotspot←0
      hotcells←⍬
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


    ∇ setlamp color         ⍝ set the solution indicator lamp
      :Access Public
     
      lampcolor←color
      :Select color
      :Case 'Orange'
          butn5.FillCol←200 200 0      ⍝ Orange = Thinking
      :Case 'Red'
          butn5.FillCol←200 0 0        ⍝ Red   = no solution possible
          redlamp+←1
          :If redlamp=1
              :If starttime≢⍬
                  errorfree←0⌈nofrozenpieces-1
                  firsterror←1
              :Else
                  redlamp←0
              :EndIf
          :EndIf
      :Case 'Green'
          butn5.FillCol←0 200 0        ⍝ Green   = a solution is possible
          greenlamp+←starttime≢⍬
      :Case 'Gray'
          butn5.FillCol←200 200 200     ⍝ of
      :Else
          butn5.FillCol←0 0 0           ⍝ black = no answer in 10 seconds.
          lampcolor←'Black'
      :EndSelect
    ∇

    :EndSection

⍝========================== class defs =======================================

    :class solvebox

        :field Public thebox             ⍝ Unique id of the piece
        :field Public main               ⍝ canves form
        :field Public c4
        :field Public lastplacement←⍬
        :field Public filcol←100 100 100

        ∇ new(form pboxdim coordinate4D)
          :Access Public
          :Implements Constructor
         
         
          passive active frozen←⍳3        ⍝ piece mode
          left right←1 2
          freezetime placement polyomino color←⍳4
          top←##
         
          boxdim←¯3↑pboxdim     ⍝ 2 3 11
          puzldimensionality←≢pboxdim
         
          main←form
          main.Event←('MouseDown' 'shoot&')('MouseUp' 'mousenull&')
          :If puzldimensionality=4
              scaleit 4
              c4←coordinate4D
              freespace←c4,¨,⍳boxdim
          :Else
              c4←⍬
              scaleit 9
              freespace←,⍳boxdim
          :EndIf
         
          boxspace←freespace
          boxframe←(,⍳boxdim+1)~⍳boxdim
          thebox←⎕NEW #.polyominod((⌽↑boxframe)(3⍴¨150 100 50))
          thebox.makepalette
          thebox.draw main
          hittencells←0
        ∇



⍝========================== callbacks =========================================

        ∇ shoot msg;pos;yxpos;hotpiece;direction;affectedcell        ⍝ Make hotspot, Call back from mouse down
          :Hold 'Box'
              pos←msg[2 3]
              mousebutn←4⊃msg
              yxpos←⊂min+difsize×pos              ⍝ Position in polygon coordinates  ⍝ yxpos←⊂(dif×pos÷size)+min
              :If mousebutn=left                    ⍝ Make new hotcell
                  hitcell direction←⊂∘⌽¨thebox.markfacex yxpos   ⍝  the hitten polygon, and get the cellid
                  :If hitcell≢⍬
                      affectedcell←⊂c4,⊃hitcell+direction
                      hitcell←⊂c4,⊃hitcell
                      ⍝ 'hit'affectedcell hitcell direction((##.theactivepiece))
                      :If ⍬≢top.theactivepiece
                      :AndIf hitcell∊top.theactivepiece.currentplacement
                         ⍝ ignore hitting the active peace          ⍝ Prevent hit the active
                         ⍝ ⎕←'ignor'
                      :ElseIf affectedcell∊boxspace
                          thebox.paintyellow        
                          thebox.draw main
                          top.frozenpieces.contains hitcell
                          hittencells+←1    
                          :If ~affectedcell∊##.hotcells
                              ##.hotcells,←affectedcell
                              :If 3<≢##.hotcells
                                  ##.hotcells↑⍨←¯3
                              :EndIf
                              :If ⍬≢##.theactivepiece
                                  ##.theactivepiece.hotspotchange   ⍝   man ⍝ call into a piece ⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
                              :EndIf
                          :EndIf
                          :If ⍬≡top.theactivepiece
                            3 top.selectstate ⍬
                          :endif
                      :EndIf
                  :EndIf
              :ElseIf mousebutn=right              ⍝ Remove hotcell
                  repaint
              :EndIf
          :EndHold
        ∇

        ∇ mousenull
           ⍝ default on mouseup, preventing strange behaveor
        ∇

       ⍝================================================utils ==========

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

        ∇ scaleit scalefac
         
          main.XRange←scalefac×¯1 1
          main.(YRange←XRange×Aspect)
          difsize←|main.((-/¨YRange XRange)÷Size)                                       ⍝ Scalefactor
          min←main.(⌊/¨YRange XRange)
          size←main.Size
        ∇

        ∇ zoominout leftright
          :Access Public
         
          scaleit(|⊃main.XRange)×leftright⊃1 0.8 1.25
          thebox.draw main
        ∇


        ∇ removebox
          :Access Public
         
          thebox.remove 0
          thebox.draw main
        ∇

        ∇ removelastx
          :Access Public
         
          :If lastplacement≢⍬
              thebox.removelast
          :EndIf
        ∇

        ∇ removelast
          :Access Public
         
          :If lastplacement≢⍬
              thebox.removelast
              thebox.draw main
          :EndIf
        ∇

        ∇ dropbox   ⍝ Drop box platform
          :Access Public
         
          thebox.remove 0
          thebox.draw main
        ∇

        ∇ repaint;starts;sizes;ids;fp;fpvolume   ⍝ remove yellow hotspots
          :Access Public
         
          :If 0<hittencells
              thebox.repaintall
              thebox.draw main
              ##.pieces.hashotspot←0
              hittencells←0
          :EndIf
        ∇

        ∇ drawit(curpl color);boxcurpl;isold;isfrozen;dumy    ⍝ Function that draws the boxes
          :Access Public
          :If ⍬≢c4
              boxcurpl←boxspace∩curpl
              placement←c4,⌽0 1↓↑boxcurpl    ⍝ theactivepiece.currentplacement
          :Else
              placement←⌽↑boxcurpl←curpl                    ⍝ theactivepiece.currentplacement
          :EndIf
          :If boxcurpl≢⍬
              thebox.addnewwithcolor placement color   ⍝ theactivepiece.pfc
              thebox.draw main
              lastplacement←placement
          :EndIf
        ∇

    :endclass   ⍝ solvebox


    :class solvepiece                     ⍝ class for temporarely pieces during the game

        :field Public id                ⍝ Unique id of the piece
        :Field Public placements        ⍝ Actual possible placements in the box
        :Field Public totplacements     ⍝ Total possible placements in the box
        :Field Public polyd             ⍝ Polyominod displayobject
        :field Public volume            ⍝ Polyomino volume
        :field Public dimension         ⍝ Polyomino dimension
        :field Public globalid          ⍝ Polyomino globalid
        :Field Public countplacements   ⍝ count actual possible placements in the box
        :Field Public hotspots←⍬        ⍝ Reserved set of hotcells
        :Field Public ppm←⍬             ⍝ Set of placements belonging to the current hotspots
        :Field Public state             ⍝ 0=passive, 1=active, , 3=frozen.
        :field Public cppm              ⍝ the current number of placements in freespace
        :field Public hashotspot←0      ⍝ If the piece has a hotspot
        :Field Public currentplacement←⍬     ⍝ Current placement of piece
        :Field Public impossibleplacements←⍬ ⍝ Placements found to be impossible
        :Field Public freezelevel←0          ⍝ Number of frozen pieces when first impossible placement found
        :field Public pfc               ⍝ the color
        :field Public ppix←0            ⍝ Pieceplacement index
        :field Public chirallabel←' '   ⍝ Chiral label: blank, L, R or L+R
        :field Public chiral←0          ⍝ Chiral indicator
        :field Public freezetime←0      ⍝ Time of freezing, seconds since play start
        :field Public freezeplacement←⍬ ⍝ Placement at time of freezeing


        ∇ new(pplacements ppolyd)       ⍝ For the box as piece
          :Access Public
          :Implements Constructor
         
          placements←pplacements
          chiral←0                      ⍝ pchiral
          pfc←ppolyd.filcol
          polyd←{#.⎕NEW #.polyominod(⍵ ⍬ ⍬ ⍬ ⍬)}¨ppolyd             ⍝ A fresh copy of polyominod
          volume←≢polyd.polyomino
          passive active frozen←⍳3                                  ⍝ Categories of state
          state←passive
        ∇

        ∇ new2(pplacements vol dim no pchiral farve)  ⍝ The normal non box pieces
          :Access Public
          :Implements Constructor
         
          placements←pplacements
          chiral←pchiral
          pfc←farve
          polyd←#.⎕NEW #.polyominod(vol dim no farve)              ⍝ A fresh copy of polyominod
          volume dimension globalid←vol dim no
          passive active frozen←⍳3                                  ⍝ Categories of state
          state←passive
        ∇

        ∇ chiraladjust leftright
          :Access Public
         
          :Select leftright
          :Case 'L'
              placements←((≢placements)÷2)↑placements          ⍝ throw away the rights in last half
              chirallabel←'L'
          :Case 'R'
              placements←((≢placements)÷2)↓placements           ⍝ throw away the lefts in first half
              polyd.mirror
              chirallabel←'R'
          :Case 'V'
              chirallabel←'L'
          :Case 'H'
              polyd.mirror
              chirallabel←'R'
          :Case 'B'
              chirallabel←'L+R'
          :Else
          :EndSelect
         
          totplacements←placements                               ⍝ for all pieces
          countplacements←≢placements
        ∇

        ∇ jumprandom;newcells;nextplacement      ⍝ the active piece are thrown into the box at random
          :Access Public
         
          ppm←placements
          state←active
          cppm←≢ppm
          id←##.(1+nofrozenpieces)
          hotspotchange
          :If cppm>0
              ppix←(#.?)cppm
              currentplacement←↓ppix⊃ppm
              state←frozen
              freezeit                        ⍝ ##.freeze currentplacement    ⍝ distribute consequenses
          :Else                               ⍝ the piece dosent fit
              ##.setlamp'Red'
              state←passive
          :EndIf
        ∇

        ∇ jumpintobox;newcells;nextplacement;timebetween
          :Access Public
         
          ppm←placements
          state←active
          ppix←0
          cppm←≢ppm
          id←##.(1+nofrozenpieces)
          hotspotchange
          :If cppm>0
              :Repeat           ⍝ movearound       ⍝ The active piece Moves around in the box
                  timebetween←⎕TS
                  currentplacement←↓(cppm|ppix)⊃ppm
                  ##.drawit                    ⍝ call into mainprogram
                  ppix←cppm|ppix+1
                  timebetween←(0.5-0.5⌊|(0 0 86400 3600 60 1 0.001)+.×⎕TS-timebetween)
                  ⎕DL timebetween
              :Until state≠active  ⍝frosen or jumpout
              :If state=frozen
                  freezeit ⍝ currentplacement    ⍝ distribute consequenses
              :EndIf
          :Else                           ⍝ the piece dosent fit hotspot
              ##.setlamp'Red'
              state←passive
          :EndIf
        ∇

        ∇ freezeit        ⍝ The peace has just frozen
         
          freezeplacement←currentplacement
          ##.freeze currentplacement    ⍝ distribute consequenses
          freezetime←##.curdur
          :If ##.solfound         ⍝ if game over
              ##.fanfare
          :EndIf
        ∇

        ∇ hotspotchange;p1;p2;p3;p11;p123;p12;p13;p23;nohotcells;ppmt
          :Access Public
         
          nohotcells←≢##.hotcells
          ppmt←⍬
          ⍝ ⎕←'# hot cells'nohotcells
          hotreduct←{(∨/↑(↓¨⍵)∊¨⊂⍺)/⍵}
          :If (1≤nohotcells)∧state=active
              ppmt←p1←##.hotcells[0]hotreduct placements
              ⍝type=single
          :AndIf 2≤nohotcells
              p2←##.hotcells[1]hotreduct placements
              p11←p1 p2
              p12←p1∩p2
              :If 0<≢p12
                  ppmt←p12  ⍝type=pair
              :Else
                  ppmt←p1∪p2  ⍝type=2singles
              :EndIf
          :AndIf 3≤nohotcells
              p3←##.hotcells[2]hotreduct placements
              p13 p23←p11∩¨,⊂p3
              p123←p12∩p13∩p23
              :If 0<≢p123
                  ppmt←p123 ⍝type=triple
              :Else
                  ppmt←p12∪p13∪p23 ⍝type=triplepairs
                  :If 0=≢ppmt ⍝ no pairs
                      ppmt←p1∪p2∪p3 ⍝type=3singles
                  :Else  ⍝ at least one pair, prepare for deletion of hotspot
                      :If 0<≢p12
                          ppmt←p3∪p12
                      :ElseIf 0<≢p13
                          ppmt←p2∪p13
                      :ElseIf 0<≢p23
                          ppmt←p1∪p23    ⍝ maybe p1 is single
                      :EndIf
                  :EndIf
              :EndIf
          :EndIf
          :If 0<≢ppmt
              :Hold 'ppm'
                  ppm←ppmt
                  ppix←0
                  cppm←≢ppm
              :EndHold
          :EndIf
          :If 1=cppm
              state←frozen
              currentplacement←↓⊃ppm
          :ElseIf (0<≢##.hotcells)∧0=cppm
              ##.setlamp'Red'
          :EndIf
        ∇

        ∇ contains hotspot         ⍝ Maintains hashotspot
          :Access Public
         
          :If ~hashotspot
              hashotspot←(⊂hotspot)∊currentplacement
          :EndIf
        ∇ 

        ⍝ touch←{0<≢⍺∩↓⍵}    ⍝ cell touch a pi

        ∇ res←counthotplacements hotspot         ⍝ Counts placements containing hotspot
          :Access Public
        
          res←+/(⊂hotspot){⍺∊↓⍵}¨placements
          ⍝:if res=2
⍝             #.a,←⊂ hotspot ((((⊂hotspot){⍺∊↓⍵}¨placements))/placements)(#.count placements)
⍝          :endif
        ∇

        ∇ jumpoutofbox
          :Access Public
          state←passive
         
          hashotspot←0
          currentplacement←⍬
        ∇

        ∇ res←overlabsort ppm;first;rest;ovl  ⍝ Maximize the overlab
          res←⍬
          rest←ppm
          overlab←{≢(↓⍺)∩↓⍵}
          :For i :In ⍳≢rest
              res,←first←1↑rest
              rest←1↓rest
              ovl←(first)overlab¨rest
              rest←rest[⍒ovl]
          :EndFor
        ∇

          fixreduct←{⍝ Reduces placements ⍺ for fixed, occupied or illegal place in ⍵
              (⍺{0=≢(↓⍺)∩⍵}¨⊂⍵)/⍺
          }

        ∇ reduct curplac                     ⍝ Reduce placements after a frozen piece
          :Access Public
         
          placements fixreduct←curplac
          countplacements←≢placements
        ∇

        ∇ removeimpossibleplacement nofrozen                     ⍝ Remove impossible placement
          :Access Public
         
          impossibleplacements,←⊂↑currentplacement
          :If freezelevel=0
              freezelevel←nofrozen
          :Else
              freezelevel⌊←nofrozen
          :EndIf
          countplacements←≢placements
        ∇


        ∇ newplacements nofrozen                  ⍝ Recalculate possible placements
          :Access Public
         
          :If freezelevel>nofrozen
              impossibleplacements←⍬
              freezelevel←0
          :EndIf
         
          placements←totplacements fixreduct ##.(boxspace~freespace)
          placements~←impossibleplacements
          countplacements←≢placements
        ∇

        ∇ replay
          :Access Public
         
          placements←,⊂↑freezeplacement
          countplacements←1
          state←passive
        ∇

        ∇ res←isfrozen
          :Access Public
         
          res←state=frozen
        ∇

    :endclass  ⍝ Piece

    :Class polySolve    ⍝ Tell if there are any solutions

        :Field Public sollimit←1
        :Field Public pivotpiece←⍬
        :Field Public result←0               ⍝ Solution indicator
        :Field Public status
        :field Public timeout←0


        ∇ new(boxdim unusedcount pieceplacements freespace timeoutlim)
          :Access Public
          :Implements Constructor
         
          starttime←2⊃⎕AI      ⍝ starttime in milliseconds
          timelimit←timeoutlim×1000      ⍝ timeoutlimit in seconds
          pcount←1+unusedcount
          pmultipliers←pcount⍴1
          pivotpiece←0
          pivotplacements←⊂,⊂↑(,⍳boxdim)~freespace
          pieceplacements←pivotplacements,pieceplacements
         
          solversetup
         
          ppbits solve pivotpiece(⍳boxvol)pmultipliers
        ∇

      ⍝-------------------------- ⍝ Prepare the solving process ----------------------

        ∇ solversetup
          dim←⊃⍴boxdim
          boxvol←⊃×/boxdim
          boxadr←,⍳boxdim
          cellids←boxdim⍴⍳boxvol
          mirs←,⍳dim⍴2
          mire miru←mirsplit mirs
          perms←adrperm dim
          perme permu←permsplit perms
          boxperm←eqperm boxdim
          pindex←⍳pcount
          totpcount←+/pmultipliers
          totpindex←⍳totpcount
          pmindex←pmultipliers/pindex
          pivotcount←⊃⍴pivotplacements
          ppcount←up⍴¨pieceplacements
          ppidx←{{⍵[⍋⍵]}cellids[↓⍵]}¨¨pieceplacements
          ppbits←⊃,[0]/(↓pindex∘.=pindex){↑⍺∘,¨(⍳boxvol)∘∊¨⍵}¨ppidx
         
          status←((1+totpcount),3)⍴0 0 0
          quadstart←⎕TS
          starttsp←(¯1↓2↓quadstart)+.×86400 3600 60 1
          solbox←boxvol⍴0
          solstack←(1+totpcount)⍴0
          presol←(sollimit totpcount)⍴99
          solnum←0
          fpc←0             ⍝ first pivot piece count
         
        ∇

    ⍝----------------------- Minor utility functions -------------------------------------


          showsol←{⍝ Pic a solution and converts it to polyominoes
              solutions[⍵;]⊃¨pmultipliers/pieceplacements
          }

        ∇ z←sol solno    ⍝ To call showsol from outside
          :Access public
          z←showsol solno
        ∇


          alleq←{⍝ Is all elements of a vector eq
              ⊃∧/2=/⍵
          }

          mirsplit←{⍝
              (0 1=⊂≠/¨⍵)/¨⊂⍵
          }

          permsplit←{⍝
              (1 ¯1=⊂permsign¨⍵)/¨⊂⍵
          }

          adrperm←{⍝ Imports a set of permutations     
              ↓(-(!⍵)⍵)↑#.polyDB.perm9    ⍝ ⍵⊃#.polyDB.allperm 
          }

          eqperm←{⍝ permutations of equal elements in a vector
              ,⊃(∘.+)/{(⊂⍵)\¨(⊂⍵/⍳⍴⍵){⍺[⍵]}¨adrperm+/⍵}¨↓(∪⍵)∘.≡⍵
          }

          adrlift←{⍝ Lifts a polyomino to higer dimension, by padding zeros to each celladress
              ↑(-⍺)↑¨↓⍵
          }

          up←{⍝ catenates a vector of nested elements
              ⊃,/⍵
          }

          adrturnit←{⍝ Transpose
              ⍵[;⍺]
          }

          cyclesign←{⍝ Sign of permutation on cycleform
              ⊃(1 ¯1)[⊃2|+/¯1+⍴¨⍵]
          }

        ∇ res←cycles perm;rest;i;j;cycle   ⍝ Find cycles of a permutation
          rest←perm
          res←⍬
          :Repeat
              i←j←⊃rest
              cycle←⍬
              :Repeat
                  rest~←cycle,←j←perm[j]
              :Until j=i
              res,←⊂cycle
          :Until rest≡⍬
        ∇

        permsign←cyclesign∘cycles    ⍝ Splits a permutation into cycles

          adrmirrorit←{⍝ Takes a mirror ⍺ and applies it to polyomino ⍵
              |⍵-(⍴⍵)⍴((⌈⌿⍵)+⌊⌿⍵)×⍺
          }

          adr2bitmap←{⍝ Converts a polyomino to binary indication in box
              (⍳boxdim)∊↓⍵
          }

          normal←{⍝ Normalization of a box containing a piece or solution
              {⊃⍵[1↑⍒↑,¨⍵]}mirs boxperm boxturns ⍵
          }

          boxturns←{⍝ Turns a boxed solution or piece
              mirs perms←⍺
              up{mirs boxmirror¨⊂⍵}¨perms⍉¨⊂⍵
          }

          boxmirror←{⍝
              ⊃{⌽[⍺]⍵}/(⍺/⍳dim),⊂⍵
          }


        ∇ polylist←polysep celladrs;poly;adr;polylist;compass;c
      ⍝ Separates a set of cells into a set of polyominoes
         
          polylist←⍳0
          compass←(-c),(⊂dim⍴0),c←↓(⍳dim)∘.=⍳dim   ⍝ Neighbour directions in space
         
          :While 0<⍴celladrs
              poly←0⍴adr←1↑celladrs
              :Repeat
                  celladrs~←poly,←adr←celladrs∩,compass∘.+adr
              :Until 0=⍴∊adr
              polylist,←⊂poly
          :End
        ∇

        ∇ res←a adrdif b;shift;mir;perm;sign;av;ad;bv;bd;as;bs;an;bn;flip;bndim;psign
      ⍝  Find a linear transformation of a that matches b
         
          res←shift←mir←perm←sign←⍬
          (av ad)(bv bd)←⍴¨a b
          :If av=bv                     ⍝ same volume
              :If ad<bd                 ⍝ lift to same dimension
                  a←bd adrlift a
                  ad←bd
              :ElseIf ad>bd
                  b←ad adrlift b
              :EndIf
              as bs←{⌊⌿⍵}¨a b
              an bn←(↑(↓a)-⊂as)((↓b)-⊂bs)
              bndim←⌈⌿↑bn
              :For perm :In adrperm ad
                  flip←perm adrturnit an
                  psign←permsign perm
                  :If bndim≡⌈⌿flip  ⍝ same case orientation
                      :For mir :In ⍳ad⍴2
                          :If 0=⍴bn~↓mir adrmirrorit flip
                              sign←(1 ¯1)[≠/mir]×psign   ⍝ Determinant of transformation
                              res←mir perm as bs sign
                              :If sign≡1 ⋄ :Leave ⋄ :EndIf
                          :EndIf
                      :EndFor
                  :EndIf
                  :If sign≡1 ⋄ :Leave ⋄ :EndIf
              :EndFor
          :EndIf
        ∇

          statuslog←{⍝ Updates the status matrix
              status[pieceno;]←(⎕TS)(⊃status[pieceno;1]+1)(⍵)
              timelimit<(2⊃⎕AI)-starttime
          }

    ⍝------------- The main soving procedure (recursive) ---------------------------------------


        ∇ allbits solve(minidex colindex pmcount);pieceno;pcase;restbits;npm;pivid;pivot;reducedbits;colsum;min;rpivot;idlng
          idlng pieceno←(⊃⍴pmcount)(⊃+/pmcount)
          :If timeout
              :Return
          :EndIf
          :If pieceno>1
              :If pcase←minidex<idlng    ⍝ piece case
              :AndIf 1<minidex⊃pmcount
                  restbits←allbits       ⍝ piece has clones
              :Else
                  restbits←(~allbits[;minidex])⌿allbits
              :EndIf
              :If statuslog('FP'[pcase])(⍴restbits)    ⍝ Field or Piece
                  timeout←1
                  :Return
              :EndIf
              :For pivot :In ↓allbits[;minidex]⌿allbits
                  npm←pmcount
                  npm-←pivid←idlng↑pivot
                  :If 0<pivid/npm ⋄ (idlng↑pivot)←0 ⋄ :EndIf  ⍝ zero out clone id
                  min←⊃⌊/colsum←+⌿reducedbits←(~pivot)/(~restbits∨.∧pivot)⌿restbits
                  :If 0<min
                      solstack[pieceno]←⊂(pivid/⍳⍴pivid)((rpivot←idlng↓pivot)/colindex)
                      reducedbits solve(colsum⍳min)((~rpivot)/colindex)((npm>0)/npm)
                      :If timeout∨solnum=sollimit ⋄ :Return ⋄ :EndIf
                  :EndIf
                  :If pieceno=totpcount     ⍝ First Pivot piece
                      fpc+←1
                  :AndIf fpc=pivotcount     ⍝ and final pivot pp
                      :Return
                  :EndIf
              :EndFor
          :Else   ⍝ there is a solution
              result←1
              solstack[1]←⊂0 colindex
              ⍝ statuslog(⊂'Sol')(⍴allbits)
              solnum+←1
          :EndIf
        ∇

    :EndClass   ⍝ polySolve

:EndClass  ⍝ testPuzzlMan4d
