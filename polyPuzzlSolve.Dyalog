:Class polyPuzzlSolve    ⍝ Solves specified puzzle and monitors the process 
 
⍝ The user should be able to suspend and resume the process that can be timeconsuming
⍝ The process should run in its own thread  nn

    :Field Public boxdim
    :Field Public pieces      
    :Field Public pmultipliers←⍬       
    :Field Public sollimit
    :Field Public pieceplacements
    :Field Public pmindex
    :Field Public solutions 
    :Field Public solx                                  
    :Field Public status 
    :Field Public Setuplog
    :Field Public chiral   ⍝ ity
    :Field Public pivotpiece←⍬
    :Field Public pivotplacements←⍬
    :Field Public puzzle
    :Field Public dim
    :Field Public boxvol
    :Field Public defmat
    :Field Public solstack
    :Field Public fase←0
    :Field Public fixedmask←⍬
    :Field Public smat←⍬
    :Field  startit←0
    
    :include #.polyFns    ⍝Util

    ∇ new subform
      :Access Public     
      :Implements Constructor
     
      guisetup subform
      reset
    ∇
     
    ∇ guisetup subform;statusmat;i;rno;cno;sz
      ⍝ for with 2 subforms: specifikation and monitor
     
      solform←subform makeformu(10 30 5 50 5)(5 40 5 40 10)
      headf statf startf←solform.subforms[0 3 4;3]        ⍝ Shorthand names
      defheadf deff←solform.subforms[0 3;1]        ⍝ Shorthand names
      poly0 poly1←solform.subforms[1;1 3]        ⍝ Shorthand names
      topline←solform.subforms[2;3]
      underline←solform.subforms[2;1]
     
      GUInames
     
      :With Label1←defheadf.⎕NEW Label(⊂Caption'Choose a puzzle')
          FontObj←'ARIAL' 25 0 ⋄ Size←20 220 ⋄ Posn←20 0
      :EndWith
     
      :With Label2←defheadf.⎕NEW Label(⊂Caption' ')
          FontObj←'ARIAL' 25 0 ⋄ Size←20 220 ⋄ Posn←45 0
      :EndWith
     
      :With Label3←defheadf.⎕NEW Label(⊂Caption' ')
          FontObj←'ARIAL' 25 0 ⋄ Size←20 220 ⋄ Posn←20 225
      :EndWith
     
      :With Label4←headf.⎕NEW Label(⊂Caption'Solve it')
          FontObj←'ARIAL' 25 0 ⋄ Size←20 200 ⋄ Posn←20 0
      :EndWith
     
      :With manually←headf.⎕NEW Button(⊂Style Push)
          FontObj←'ARIAL' 20 0 ⋄ Caption←'Manually →' ⋄ Size←20 150 ⋄ Posn←20 300
      :EndWith
     
     
    ⍝-------------------- Polyomino windows, single left poly0 and solution right poly1 -----------------------
     
      scalefac←8
      poly0.XRange←scalefac×1 ¯1
      poly0.(YRange←XRange×-Aspect)
      poly0.Event←(MouseDown'shoot&')
    ⍝ poly0.Event←(MouseEnter'rotate&'poly0)(MouseLeave'stoprot&')       ⍝  (MouseDown'rotate&'poly0)
     
      dif←(1 ¯1)×|poly0.(-/¨YRange XRange)                                       ⍝ Length of ranges
      min←(1 ¯1)×poly0.(⌊/¨YRange XRange)
      size←poly0.Size
      poly0.Visible←0
     
      scalefac←8   ⍝+0⌈0.25×maxheight-5
      poly1.XRange←scalefac×1 ¯1
      poly1.(YRange←XRange×-Aspect)
      poly1.Event←(MouseEnter'rotate&'poly1)(MouseLeave'stoprot&')(MouseDown'rotate&'poly1)
      poly1.Visible←0
      pieceno←0
     
      :With poly1a←poly1.⎕NEW Edit((Style Multi)(VScroll ¯1)(HScroll ¯1)(FieldType Char))
          FontObj←'APL385 Unicode' 15 ⋄ Size←##.Size ⋄ Posn←0 0 ⋄ Visible←0
      :EndWith
     
     ⍝----------- Fixed pos and restrict search space buttons -----------------
     
      fixbackward←underline.⎕NEW Button(⊂Style Push)
      fixbutn←underline.⎕NEW Button(⊂Style Push)
      fixforward←underline.⎕NEW Button(⊂Style Push)
      fixleft←underline.⎕NEW Button(⊂Style Push)
      fixright←underline.⎕NEW Button(⊂Style Push)
      i←0
      :For Cap :In fixbackward fixbutn fixforward fixleft fixright
          Cap.FontObj←ARIAL 20 0 ⋄ Cap.Size←20 50 ⋄ Cap.Posn←0 i ⋄ i+←60
      :EndFor
      (fixbackward fixbutn fixforward fixleft fixright).Caption←'←' 'x' '→' 'L' 'R'
     
      fixbackward.Event←⊂Select'fixforthback&' 0
      fixforward.Event←⊂Select'fixforthback&' 1
      fixbutn.Event←⊂Select'fixit&'
      fixleft.Event←⊂Select'fixL&'
      fixright.Event←⊂Select'fixR&'
     
      (fixleft fixright).Visible←0        ⍝ Awaits implementation
     
     ⍝----------- Topline Solution step buttons -----------------
     
      backward←topline.⎕NEW Button(⊂Style Push)
      forward←topline.⎕NEW Button(⊂Style Push)
      solnobackward←topline.⎕NEW Button(⊂Style Push)
      solnoforward←topline.⎕NEW Button(⊂Style Push)
      dropbox←topline.⎕NEW Button(⊂Style Push)
      allsol←topline.⎕NEW Button(⊂Style Push)
      i←0
      :For Cap :In solnobackward solnoforward backward forward dropbox allsol
          Cap.FontObj←ARIAL 20 0 ⋄ Cap.Size←20 40 ⋄ Cap.Posn←0(i⊃0 120 165 210 255 300)
          Cap.Caption←i⊃'<<' '>>' '←' '→' 'X' 'All' ⋄ i+←1
      :EndFor
      backward.Event←⊂Select'back&'
      forward.Event←⊂Select'forw&'
      solnobackward.Event←⊂'Select' 'solnoforth&' ¯1
      solnoforward.Event←⊂'Select' 'solnoforth&' 1
      dropbox.Event←⊂'Select' 'dropboxx&'
      allsol.Event←⊂'Select' 'allsolx&'
     
      Solno←topline.⎕NEW Edit(⊂Value'0')             ⍝ solution number for display
      :With Solno
          FontObj←'ARIAL' 15 ⋄ Size←20 60 ⋄ Posn←0 50
      :EndWith
      Solno.Event←MouseLeave'setsolno&'
     
      boxCombo←topline.⎕NEW Combo((VScroll ¯1)(Style'Drop')) ⍝ solution box orientation
      :With boxCombo
          FontObj←'ARIAL' 14
          Posn←0 405
          Size←15 75
          Items←'0 0 0'
      :EndWith
      boxCombo.Event←Select'selectbox&'
     
   ⍝--------------------------- grid forms ----------------------------------
     
      statusmat←5 7⍴0     ⍝ piececount 7⍴0      ⍝ statusmatrix: 1 + no of pieces x 4
     
      Grid1←statf.⎕NEW Grid(⊂CellHeights 21)
      :With Grid1
          FontObj←'ARIAL' 15
          Values←5 7⍴0
          Size←##.Size
          Posn←0 0
          CellWidths←80 80 40 40 40 40 80
          TitleWidth←50
          ColTitles←'Time' 'Count' 'Kind' 'Bit x' 'bit y' 'Pid' 'Avg time'
          GridLineFCol←0
          GridLineWidth←1
          rno cno←⍴Values
          CellTypes←(rno cno)⍴1
          ColLineTypes←(cno)⍴1
          GridLineFCol←0
          GridLineWidth←1
          Input←''
          RowLineTypes←rno⍴1
      :EndWith
     
     
      Grid0←deff.⎕NEW Grid(⊂CellHeights 21)
      :With Grid0
          FontObj←'ARIAL' 15
          Values←5 10⍴0  ⍝ defmat
          Size←##.Size
          Posn←0 0
          CellWidths←40 40 40 40 40 40 40 40 40 40
          TitleWidth←50
          ColTitles←'Pid' 'Place' 'Reduct' 'Chiral' 'R - L' 'Left' 'Right' 'Fixed' 'Stop' 'Freeze'
          GridLineFCol←0
          GridLineWidth←1
          rno cno←⍴Values
          CellTypes←(rno cno)⍴1
          ColLineTypes←(cno)⍴1
          GridLineFCol←0
          GridLineWidth←1
          Input←''
          RowLineTypes←rno⍴1 
          Visible←0
      :EndWith
      ⍝ Grid0.Event←(CellDown'selectpiece&')
     
      SolveControl←startf.⎕NEW Button(⊂Caption'GO')          ⍝ Start the solving proces
      :With SolveControl
          FontObj←'ARIAL' 15 ⋄ Size←24 50 ⋄ Posn←0 100 ⋄ Style←'Push'         ⍝'Check'
      :EndWith
      SolveControl.Event←Select'solveit&'
     
      Sollimit←startf.⎕NEW Edit(⊂Value'1E1')
      :With Sollimit
          FontObj←'ARIAL' 15 ⋄ Size←24 50 ⋄ Posn←0 0
      :EndWith
      Sollimit.Event←MouseLeave'setsollimit&'
     
   ⍝------------------- Combo boxes for puzzle selection -----------------------
     
      puzlCombo←defheadf.⎕NEW Combo((VScroll ¯1)(Style'Drop'))
      :With puzlCombo
          FontObj←'ARIAL' 15
          Posn←75 0
          Size←25 125
          Items←#.pdb.puzzleCollection.name
      :EndWith
      puzlCombo.Event←Select'selectpuzzle&'
     
      resetButn←defheadf.⎕NEW Button(⊂Caption'Reset')
      :With resetButn
          Size←25 125
          Posn←75 350
          Style←'Push'
      :EndWith
      resetButn.Event←Select'resetbutn&'
    ∇
    
    ⍝------------------ puzzle setup and filling the defining grid -----------------------------

    ∇ puzlSetup puzzldef
     
      puzzle←puzzldef
      boxdim←puzzldef.boxdim
      allpieces←puzzldef.pieces
      allpieces←(allpieces.count>0)/allpieces    ⍝ reduce for null-pieces
      pmultipliers←allpieces.count
      pieces←allpieces.polyomino
      piececount←⊃+/pmultipliers
      pieceplacements←allpieces.placements
      chiral←allpieces.(rights-lefts)       ⍝assumning atmost one of either     ity
     
      sollimit←20
      pieceplacements←chiral chiralfilter¨pieceplacements
     
      defmat←((+/pmultipliers),10)⍴0      ⍝ statusmatrix: 1 + no of pieces x 4
      defmat[;0]←pmultipliers/⍳⍴pieces
      defmat[;1]←pmultipliers/allpieces.(⍴placements)
      defmat[;2]←pmultipliers/⍴¨pieceplacements
      defmat[;3]←pmultipliers/allpieces.chiral
      defmat[;4]←pmultipliers/allpieces.(rights-lefts)
      defmat[;5]←pmultipliers/allpieces.lefts
      defmat[;6]←pmultipliers/allpieces.rights
      ⍝ defmat[;7]←' X'[defmat[;0]=fixedpiece]
      defmat[0;8]←sollimit
     
      ⍝ solversetup
     
      Grid0.Values←defmat
      Grid1.Values←piececount 7⍴0
     
      polybox←(,⍳boxdim+1)~,⍳boxdim
     ⍝ theleftbox←#.⎕NEW #.polyominod((⌽↑polybox)(3⍴¨150 100 50))
      ⍝ theleftbox←#.⎕NEW #.polyominod(,⊂⌽↑polybox)
     ⍝ theleftbox.makepalette
     ⍝ theleftbox.addnewwithcolor((⌽0⊃0⊃pieceplacements)(3⍴⊂3⍴10))
    ∇
    
    ∇ reset          ⍝ Reset before a new puzzle is chosen
      startit←fase←0
      pivotpiece←⍬
      solutions←⍬
      pieceno←0
      Grid0.Values←5 10⍴0
      Grid1.Values←5 7⍴0
      Label1.Caption←'Choose a puzzle'
      SolveControl.Caption←'Start'
      poly0.Visible←0
      poly1.Visible←0
      poly1a.Visible←0
      (backward forward dropbox).Visible←1
      poly1a.Text←' '
    ∇
    
    ⍝-------------------------- ⍝ Prepare the solving process ----------------------
        
    ∇ solversetup
     
      dim←⊃⍴boxdim
      ⍝ boxvol←⊃×/boxdim
      boxadr←,⍳boxdim
      cellids←boxdim⍴⍳boxvol
      mirs←,⍳dim⍴2
      mire miru←mirsplit mirs
      perms←adrperm dim
      perme permu←permsplit perms
      boxperm←eqperm boxdim
      pcount←⍴pieces
      pindex←⍳pcount
      totpcount←+/pmultipliers
      totpindex←⍳totpcount
      pmindex←pmultipliers/pindex
      :If ⍬≡pivotpiece
          ppcount←up⍴¨pieceplacements
          pivotpiece←ppcount⍳⌈/ppcount
          pivotplacements←pivotpiece⊃pieceplacements
          pivotplacements←pivotplacements[s⍳∪s←normal∘adr2bitmap¨pivotplacements]
      :EndIf
      (pivotpiece⊃pieceplacements)←pivotplacements,(pivotpiece⊃pieceplacements)~pivotplacements
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
     
    ⍝  ⎕←st2←⎕TS'Search'sollimit'Loop'pivotcount'Box'boxdim'Pie.'totpcount'Kinds'pcount
    ∇
    
      ⍝-------------------------- Run the solving process ----------------------
    
    ∇ runit   ⍝ Run the solving process
      :If fase=0   ⍝ Activate the solving process first time
          solversetup
          defmat[;2]←pmultipliers/⍴¨pieceplacements
          defmat[pivotpiece;4]←⍴pivotplacements
          Grid0.Values←defmat
     
          ppbits solve pivotpiece(⍳boxvol)pmultipliers     ⍝ the core solving process
     
          aftershave
     
          orientation←0
          orientation1←1
          lastsolsetup
     
      :ElseIf fase=1            ⍝ Activate the solving process second time, with reversed active pieces
          fixedmask←alleq¨⊂[0]solutions
          freespace←⊃,/↓¨fixedmask/showsol 0
          fixedspace←(⍳boxvol)~freespace
          px←pieceplacements fixreduct¨⊂fixedspace
          pieceplacements fixreduct¨←⊂fixedspace
          ⎕←'px'(px≡pieceplacements)
          pieceplacements[(~fixedmask)/pmindex]←,∘⊂¨(~fixedmask)/showsol 0
          solx←solutions
          defmat[;2]←pmultipliers/⍴¨pieceplacements
          setupsolver
          Grid0.Values←defmat
          ppbits solve pivotpiece(⍳boxvol)pmultipliers
          aftershave
      :EndIf
      fase+←1
    ∇
    
    ∇ lastsolsetup          ⍝ Selecting last solution for display
      nosol←≢solutions
      solno←nosol-1
      Solno.Value←⍕solno
      :If (≢boxdim)∊2 3
          poly1.Visible←1
          boxCombo.Items←∪⍕¨(⍳3)⌽¨⊂boxdim         ⍝ boxorientations
          boxCombo.(Visible←1<≢Items)
          displaysol
      :ElseIf (≢boxdim)=4
          poly1.Visible←1
          poly1a.Visible←1
          (backward forward dropbox).Visible←0
          poly1a.Text←DISPLAY show2Dsol showsol solno
      :EndIf
    ∇
    
    ∇ displaysol            ⍝ Selecting another solution for display
      :If (≢boxdim)∊2 3
          sol7←orientation volsort showsol solno
          solorder←(showsol solno)⍳sol7
          polybox←(,⍳boxdim+1 0 0)~,⍳boxdim
          ⍝ thebox←#.⎕NEW #.polyominod((⌽↑boxframe)(3⍴¨150 100 50))
          thebox←⎕NEW #.polyominod(((orientation1)⌽↑polybox)(3⍴¨150 100 50))
          ⍝ thebox←⎕NEW #.polyominod(,⊂(orientation1)⌽↑polybox)
          thebox.draw poly1
      :ElseIf (≢boxdim)=4
          poly1a.Text←DISPLAY show2Dsol showsol solno
      :EndIf
    ∇
     
    ∇ displayallsol;sol;shape            ⍝ Selecting all solutions for display in new edit-window
      :If 1∊boxdim
          shape←(⌈nosol÷8)8
          sol←show2Dsol¨shape⍴(⊃×/shape)↑(0 1∘↓)¨¨showsol¨⍳nosol
      :Else
          sol←show2Dsol¨⍪showsol¨⍳nosol
      :EndIf
      ⎕ED'sol'
    ∇
     
    ⍝----------------------- Minor utility functions -------------------------------------
        
      chiralfilter←{⍝ Filter those from ⍵ with a specific relative sign
          sign←⍺
          sign=0:⍵                                                ⍝ if sign is 0, return all
          primpoly←⊃⍵
          signdif←{⊃¯1↑primpoly adrdif ⍵}¨⍵                       ⍝ last component of adrdif
          (sign=signdif)/⍵
      }
      
       
      fixreduct←{⍝ Reduces placements ⍺ for fixed, occupied or illegal place in ⍵
          (⍺{0=≢(↓⍺)∩⍵}¨⊂⍵)/⍺
      }
         
      showsol←{⍝ Pic a solution and converts it to polyominoes
          solutions[⍵;]⊃¨pmultipliers/pieceplacements
      }
      
    ∇ z←sol solno    ⍝ To call showsol from outside
      :Access public
     
      z←showsol solno
    ∇
         
      show2Dsol←{ ⍝ Shows a 2D puzzle solution as a character array with decoratorsigns
     
          deko←' ┌┐─┬└│├┼┘┼┼┤┴┼'        ⍝  ┌ ┐ ─ ┬ └ │ ├ ┼ ┘ ┼ ┼ ┤ ┴ ┼  ;  Vertical: 6 7 8 10 11 12 14
                                        ⍝  1 2 3 4 5 6 7 8 9 0 1 2 3 4     Hori:3 4 8 10 11 14
          wtype←(0 0 0)(0 0 1)(0 1 0)(0 1 1)(0 1 2)(1 0 0)(1 0 1)(1 0 2)
          wtype,←(1 1 0)(1 1 1)(1 1 2)(1 2 0)(1 2 1)(1 2 2)(1 2 3)
     
          adrbox←{⍝ Returns the dimensions of the envelope box
              1+⌈⌿⍵}
     
          subshow←{
              box←1 2×⍴⍵                                     ⍝ a box with duble columns
              rewrap←¯1⌽¯1⊖(box+2)↑box⍴⊃,/2\¨,⍵              ⍝ Make a rim of zeroes around the box
              deko[{wtype⍳⊂1↓(∪⍵)⍳⍵}¨⊃{2,/[⍺]⍵}/0 1 rewrap]  ⍝ Deko after neighbour conditions
          }
     
          ⍺←adrbox⊃⍪/⍵                                       ⍝ if no box in left arg, calculate it
          dim←≢boxdim←⍺
          dim=2:subshow⊃(1+⍳⍴⍵)+.×(⊂⍳boxdim)∊¨↓¨⍵
          dim≥3:subshow¨⊂[¯2↑⍳dim]⊃(1+⍳⍴⍵)+.×(⊂⍳boxdim)∊¨↓¨⍵
          ⍬
      }
    
      sol2ppadr←{ ⍝ Shows a solution as a set of pieceplacements
          (pmindex,¨solutions[⍵;])⊃¨⊂pieceplacements
      }
      
      linedetect←{⍝ Detect if dividing line is present in a 2D puzzle solution
     
          deko←⊂' ┌┐─┬└│├┼┘┼┼┤┴┼'        ⍝  ┌ ┐ ─ ┬ └ │ ├ ┼ ┘ ┼ ┼ ┤ ┴ ┼  ;  Vertical: 6 7 8 10 11 12 14
                                    ⍝  1 2 3 4 5 6 7 8 9 0 1 2 3 4
          detect←{
              indx←(⍴⍵)⍴deko⍳¨,⍵
              ∧⌿((¯1 ¯1)↓(1 1)↓indx)∊6 7 8 10 11 12 14       ⍝ Index of dekos with a vertical stroke, discard rim
          }
          ∨/⊃,/detect∘show2Dsol¨(⍵)(⌽¨⍵)                     ⍝ Also the transposed version
      }

      volsort←{⍝ Sorts pieces of a solution, so it is filled from the bottom and up
          ⍺←0
          axis←⍺
          volumedistribution←{   ⍝ distribution of polyomino volume along ⍺ axis/dimension
              up{(⊃⍵)(≢1⊃⍵)}⊃¯1↑↓groupby axis⌽⍵
          }
          ⍵[⍒↑volumedistribution¨⍵]
      }

        
      alleq←{⍝ Is all elements of a vector eq
          ⊃∧/2=/⍵
      }

      mirsplit←{⍝
          (0 1=⊂≠/¨⍵)/¨⊂⍵
      }

      permsplit←{⍝
          (1 ¯1=⊂permsign¨⍵)/¨⊂⍵
      }
       
      eqperm←{⍝ permutations of equal elements in a vector
          ,⊃(∘.+)/{(⊂⍵)\¨(⊂⍵/⍳⍴⍵){⍺[⍵]}¨adrperm+/⍵}¨↓(∪⍵)∘.≡⍵
      }
         
      adrlift←{⍝ Lifts a polyomino to higer dimension, by padding zeros to each celladress
          ↑(-⍺)↑¨↓⍵
      }
    
      adrturnit←{⍝ Transpose
          ⍵[;⍺]
      }
      
    ∇ sign←permsign perm;rest;i;j;cycle
      ⍝ Find sign of each cycle of a permutation and multiply them
      sign cycle rest←1 ⍬ perm
      :Repeat
          i←j←⊃rest
          cycle←⍬
          :Repeat
              rest~←cycle,←j←j⊃perm
          :Until j=i
          sign×←(2|≢cycle)⊃¯1 1
      :Until rest≡⍬
    ∇
    
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
    
    ⍝------------- The main soving procedure (recursive) ---------------------------------------
   
    ∇ allbits solve(minidex colindex pmcount);pieceno;pcase;restbits;npm;pivid;pivot;reducedbits;colsum;min;rpivot;idlng
      idlng pieceno←(⊃⍴pmcount)(⊃+/pmcount)
      :If pieceno>1
          :If pcase←minidex<idlng    ⍝ piece case
          :AndIf 1<minidex⊃pmcount
              restbits←allbits       ⍝ piece has clones
          :Else
              restbits←(~allbits[;minidex])⌿allbits
          :EndIf
          statuslog('FP'[pcase])(⍴restbits)    ⍝ Field or Piece
          :For pivot :In ↓allbits[;minidex]⌿allbits
              npm←pmcount
              npm-←pivid←idlng↑pivot
              :If 0<pivid/npm ⋄ (idlng↑pivot)←0 ⋄ :EndIf  ⍝ zero out clone id
              min←⊃⌊/colsum←+⌿reducedbits←(~pivot)/(~restbits∨.∧pivot)⌿restbits
              :If 0<min
                  solstack[pieceno]←⊂(pivid/⍳⍴pivid)((rpivot←idlng↓pivot)/colindex)
                  reducedbits solve(colsum⍳min)((~rpivot)/colindex)((npm>0)/npm)
                  :If solnum=sollimit ⋄ :Return ⋄ :EndIf
              :EndIf
              :If pieceno=totpcount     ⍝ First Pivot piece
                  fpc+←1
              :AndIf fpc=pivotcount     ⍝ and final pivot pp
                  :Return
              :EndIf
          :EndFor
      :Else
          solstack[1]←⊂0 colindex
          presol[solnum;]←stack2sol⌽1↓solstack
          statuslog(⊂'Sol')(⍴allbits)
          solnum+←1
          showstat
      :EndIf
    ∇
    
    ⍝------------ Solution treatment, local and global -------------------------------
    
    ∇ res←stack2sol solstack;pix;pm;px;i;ppids
     ⍝ Convert a solstack into a solution vector of ppids
      pix pm px←⍬ pmultipliers pindex
      :For i :In ⊃¨solstack
          pix,←i⊃px
          (i⊃pm)-←1
          px←(pm>0)/px
          pm←(pm>0)/pm
      :EndFor
      ppids←pix{(⍺⊃ppidx)⍳⊂1⊃⍵}¨solstack
      statuspix←⌽pix
      res←ppids[⍋pix]
    ∇
                
    ∇ aftershave   ⍝ Uniqueness and normalization of the found solutions , strip empty presol
      solnum←⊃⍴solutions←unisol(solnum totpcount)↑presol
      status[0;0]←0
      showstat
      ⍝ ⎕EX ##.##.dropvar
     ⍝ ⎕←st3←⎕TS solnum'Solutions found'(1⍕solnum÷(⎕TS diftime quadstart))'sol pr sec.'
     ⍝ Setuplog←↑⍕¨st1 st2 st3
    ∇
                                          
      unisol←{ ⍝ Give the solutions the final touch
     
          boxturn←{⍝ Turns a boxed solution or piece
              mir perm←⍺
              mir boxmirror perm⍉⍵}
     
          sol2box←{ ⍝ Transforms solution vector of ppids into a boxed solution
              ⊃totpindex+.×{cellids∊⍵⊃ppidx}¨pmindex,¨⍵}
     
          normalix←{⍝ Transformation that turns a box into its normalised representation
              bix mix←,(up⍴¨boxperm mirs)⊤1↑⍒↑,¨mirs boxperm boxturns ⍵
              (mix⊃mirs)(bix⊃boxperm)}
     
          unify←{⍝ Normalise a solution the same way as its clone-welded partner
              bs←sol2box ⍵
              ,(normalix pmindex[bs])boxturn bs}
     
          pack2sol←{ ⍝ Makes an ordered vector of ppids
              ,0 1↓{⍵[⍋⍵;]}↑⍵}
     
          findppidx←{ ⍝ Find index of ppids in ppidx
              pmindex{⍺,(⍺⊃ppidx)⍳⊂⍵}¨⍵}
     
          ppextract←{ ⍝ splits a solution into a set af ppids
              totpindex{(⍺=⍵)/⍳boxvol}¨⊂⍵}
     
     
          allsol←↓⍵[⍋⍵;]                                            ⍝ Sort solutions
     
          ∧/1=pmultipliers:↑allsol                                  ⍝ If no clones return
     
          ↑allsol[s⍳∪s←pack2sol∘findppidx∘ppextract∘unify¨allsol]   ⍝ Else unify solutions
      }
 
        
⍝------------- Status monitor of the solving process -------------------------- 

   
      statuslog←{⍝ Updates the status matrix
          status[pieceno;]←(⎕TS)(⊃status[pieceno;1]+1)(⍵)
      }

      diftime←{⍝ Gives difference in seconds between two ⎕ts timestamps
          0 0 86400 3600 60 1 0.001+.×⍺-⍵}
    
    ∇ showstat;a;b;c  ⍝ Show statistics ; sincelast; ts
      ts←⎕TS
      sincelast←ts diftime⊃status[0;0]
      :If 1<sincelast
          status[0;0]←⊂ts                                      ⍝ updates only once a second
          :For i :In ⍳totpcount     ⍝ +/pmultipliers
              j←i+1
              a b←2↑⊃status[j;2]
              b c←2↑b
              ⎕NQ'Grid1'CellChange i 0(⊂⍕3↓⊃status[j;0])
              ⎕NQ'Grid1'CellChange i 1(status[j;1])
              ⎕NQ'Grid1'CellChange i 2(⊂⍕a)
              ⎕NQ'Grid1'CellChange i 3(b)
              ⎕NQ'Grid1'CellChange i 4(c)
              ⎕NQ'Grid1'CellChange i 5(statuspix[i])
              ⎕NQ'Grid1'CellChange i 6(6⍕(-quadstart diftime⊃status[j;0])÷1⌈⊃status[j;1])
          :EndFor
          ⍝ smat←statf.Grid1.Values
          ⍝ ⎕←'hej der'(⍴smat)
      :EndIf
    ∇
   
    ⍝-------------------- callbacks -----------------------------------      
      
    ∇ dir fixforthback msg    ⍝ Step forward/backward through pieceplacements for selected piece
      ppno←((0⌈ppno-1)(cpm⌊ppno+1))[dir]      ⍝ back or forth
     
      :If ppno=0
          ppm←selectedpiece⊃pieceplacements
          pfc←allpieces[selectedpiece].polyd.filcol
          cpm←¯1+≢ppm
      :EndIf
     
     ⍝ theleftbox.removelast
⍝      theleftbox.addnewwithcolor((⌽ppno⊃ppm)(pfc))
⍝      theleftbox.draw poly0
    ∇
    
    ∇ fixit  ⍝ Reduce the pieceplacements that overlab the fixed placements
      ⎕NQ'Grid0'CellChange selectedrow 7(ppno)
      ⎕←'fixit'selectedpiece selectedrow ppno    ⍝ (ppno⊃ppm)(⍴pfc)
      fixedpiece←selectedpiece
      fixedplacements←↓ppno⊃ppm      ⍝ (0 3 3)(0 3 4)(0 4 3)(0 4 4)(1 3 3)(1 3 4)(1 4 3)(1 4 4)
      pieceplacements←pieceplacements fixreduct¨⊂fixedplacements
      pieceplacements[fixedpiece]←⊂,⊂↑fixedplacements
    ∇
    
    ∇ shoot msg;pos;yxpos;hits;hit                          ⍝ Call back from mouse down
     
      pos←msg[2 3]
      mousebutn←4⊃msg                 ⍝ 1=left 2=right
      left right←1 2
                                               ⍝ Coordinates of point   ×|dif
      yxpos←⊂(dif×pos÷size)+min                    ⍝ Position in polygon coordinates
      ⍝ hit←0≤theleftbox.markcell yxpos
      :If hit
     ⍝     theleftbox.draw poly0
      :EndIf
    ∇
    
    ∇ fixL
      ⎕←'fix L'
    ∇

    ∇ fixR
      ⎕←'fix R'
    ∇

    ∇ resetbutn          ⍝ Reset before a new puzzle is chosen
      reset
      puzlCombo.Items←#.pdb.puzzleCollection.name
    ∇
    
    ∇ selectbox;indx    ⍝ Select boxorientation
      orientation←⊃boxCombo.(SelItems/⍳⍴SelItems)
      orientation1←1+orientation
      lastsolsetup
      ⍝ ⎕←boxCombo.Text indx
    ∇
    
    ∇ dropboxx   ⍝ Drop box platform
      thebox.remove 0
      thebox.draw poly1
      ⍝  ⎕←'dropbox'
    ∇
     
    ∇ allsolx;sol;shape  ⍝ Show all solutions
      :If 1∊boxdim
          shape←(⌈nosol÷8)8
          sol←show2Dsol¨shape⍴(⊃×/shape)↑(0 1∘↓)¨¨showsol¨⍳nosol
      :Else
          sol←show2Dsol¨⍪showsol¨⍳nosol
      :EndIf
      ⎕ED'sol'
    ∇
     
         
    ∇ setsollimit   ⍝ Set number of solutions
      sollimit←⍎Sollimit.Text
      ⎕←'sollimit'Sollimit.Text sollimit
    ∇
   

    ∇ selectpuzzle;indx;puzl    ⍝ Select puzzle
      reset
      indx←⊃puzlCombo.(SelItems/⍳⍴SelItems)
      puzl←indx⊃#.pdb.puzzleCollection
      Label1.Caption←'Puzzle: ',puzl.name
      Label2.Caption←'Coll: ',puzl.collectionname
      Label3.Caption←'Box: ',puzl.boxname
      indx←#.pdb.boxDims.name⍳⊂puzl.boxname
      boxvol←#.pdb.boxDims[indx].volume
      puzlSetup puzl
    ∇
      
    ∇ forw msg                ⍝forth one piece at a time in solution
      :If (0≤pieceno)∧(pieceno<piececount)
          selectedpiece←defmat[solorder[pieceno];0]
          poly0.Visible←1
          ⍝theleftbox.removelast
     
⍝          theleftbox.addnewwithcolor((⌽pieceno⊃sol7)(allpieces[selectedpiece].farve))  ⍝ polyd.filcol))
         ⍝ theleftbox.draw poly0
        ⍝  thebox.addnewwithcolor((orientation1⌽pieceno⊃sol7)(allpieces[selectedpiece].farve))
     
         ⍝ theleftbox.addnewwithcolor((⌽pieceno⊃sol7)(allpieces[selectedpiece].polyd.filcol))
⍝          theleftbox.draw poly0
⍝          thebox.addnewwithcolor((orientation1⌽pieceno⊃sol7)(allpieces[selectedpiece].polyd.filcol))
     
          thebox.draw poly1
      :EndIf
      pieceno+←1
    ∇
     
    ∇ back msg     ⍝ backward
      pieceno-←1
      :If (0≤pieceno)∧(pieceno<piececount)
          thebox.removelast
          thebox.draw poly1
          selectedpiece←defmat[solorder[pieceno];0]
          ⍝ allpieces[selectedpiece].polyd.draw poly0
        ⍝  theleftbox.removelast
     
         ⍝ theleftbox.addnewwithcolor((⌽pieceno⊃sol7)(allpieces[selectedpiece].farve))  ⍝ polyd.filcol))
          ⍝theleftbox.draw poly0
⍝          thebox.addnewwithcolor((orientation1⌽pieceno⊃sol7)(allpieces[selectedpiece].farve))
     
       ⍝   theleftbox.addnewwithcolor((⌽pieceno⊃sol7)(allpieces[selectedpiece].polyd.filcol))
       ⍝   theleftbox.draw poly0
      :EndIf
    ∇
    
    ∇ dir solnoforth msg            ⍝ count solno up or down
      solno←0⌈(nosol-1)⌊solno+dir
      Solno.Value←⍕solno
      pieceno←0
      displaysol
    ∇
    
    ∇ setsolno                     ⍝ Set the solno
      solno←Solno.Value
      0 solnoforth 0
    ∇
    
    ∇ solveit msg                    ⍝ Callback from  start  button
      :Hold 'startsolve'
          startit+←1
          :If 1=2|startit
              SolveControl.Caption←'Stop'
          :Else
              SolveControl.Caption←'Start'
          :EndIf
      :EndHold
      :If 1=2|startit
          runit
      :EndIf
    ∇
      
    ∇ ssf rotate msg;p                       ⍝ Make a piece rotate
      rotstop←1
      :Hold 'rotation'
          rotstop←0
          :If ssf≡poly0
              p←allpieces[selectedpiece].polyd
              :Repeat
                  p.turn
                  p.draw poly0
                  ⎕DL 0.05
              :Until rotstop=1
          :Else
              :Repeat
                  thebox.turn
                  thebox.draw poly1
                  ⎕DL 0.05
              :Until rotstop=1
          :EndIf
      :Else
      ⍝leave dont bother
      :EndHold
    ∇
    
    ∇ stoprot msg
      rotstop←1
    ∇
    
    ∇ selectpiece msg
      selectedrow←6⊃msg
      selectedpiece←defmat[selectedrow;0]
      poly0.Visible←1
      allpieces[selectedpiece].polyd.draw poly0
      ppno cpm←¯1 2         ⍝ Initialization
    ∇
  
:EndClass
       
