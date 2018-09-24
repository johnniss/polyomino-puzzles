:Class polyPuzzlDef    ⍝ Define a puzzle

    :field Public collection←⍬    ⍝ Collection of polyominod's 
    :field Public boxdim←⍬
    :field Public minsize←⍬ 
    :field Public allpieces   
    :field Public sections
    :field Public box←⍬
    :field Public editsection

    :include #.polyFns     ⍝ Util

    ∇ newx subform
      :Access Public 
      :Implements Constructor
     
      GUIsetup subform
     
     ⍝ initialise with Soma puzzle
     ⍝ puzlCombo.(SelItems←0=⍳⍴SelItems)
     ⍝  selectpuzzle
    ∇
    
       
    ∇ GUIsetup subform ⍝----------- defining GUI Forms and subform -----------------------------
     
      GUInames
     
      matrixsize←7   ⍝ no of polys pr page
      rows←10        ⍝ of text
      editrows←4     ⍝ number of editrows
      mode←'new'
     
      :If subform≡⍬
          subform←⎕NEW Form(⊂'Visible' 1)
          subform.Coord←'pixel'
          subform.Size←1100 1200
          subform.Posn←80 650
      :EndIf
     
      labelx←subform.⎕NEW Label(⊂Caption'Puzzle definition')
      :With labelx
          FontObj←'ARIAL' 30 ⋄ Size←40 200 ⋄ Posn←20 500
      :EndWith
     
      main←subform makeformu(⊃,/(15 10.5),(rows⍴⊂1 2),1.5)(⊃,/15,matrixsize⍴(⊂10.5 1.5))
     
      main.subforms.(Posn+←100 0)
      matrixsf←main.subforms[1;1+2×⍳matrixsize]
      firstcol←,main.subforms[1+2×⍳1+rows;0]
      sections←main.subforms[3+2×⍳rows;1+2×⍳matrixsize]
      editsection←main.subforms[15+2×⍳editrows;1+2×⍳matrixsize]
      topline←,main.subforms[0;1+2×⍳matrixsize]
     
    ⍝ headersetup    ⍝-------------- Header information ---------------------
     
      puzllab←topline[0].⎕NEW Label(⊂Caption'Puzzle name:')
      collab←topline[1].⎕NEW Label(⊂Caption'Collection name:')
      boxlab←topline[2].⎕NEW Label(⊂Caption'Box dimensions:')
      boxvollab←topline[3].⎕NEW Label(⊂Caption'Box volume:')
      piececountlab←topline[4].⎕NEW Label(⊂Caption'Piece count:')
      piecevollab←topline[5].⎕NEW Label(⊂Caption'Piece volume:')
      solfoundlab←topline[6].⎕NEW Label(⊂Caption'Solutions found:')
     
      :For Cap :In puzllab collab boxlab boxvollab piececountlab piecevollab solfoundlab
          Cap.FontObj←ARIAL 20 ⋄ Cap.Size←25 120 ⋄ Cap.Posn←10 0
      :EndFor
     
      boxvollax←topline[3].⎕NEW Label(⊂Caption(,⍕0))
      piececountlax←topline[4].⎕NEW Label(⊂Caption(,⍕0))
      piecevollax←topline[5].⎕NEW Label(⊂Caption(,⍕0))
      solfoundlax←topline[6].⎕NEW Label(⊂Caption(,⍕0))
     
      puzlCombo←topline[0].⎕NEW Combo((VScroll ¯1)(Style DropEdit))
      :With puzlCombo
          FontObj←'ARIAL' 15 ⋄ Posn←40 0 ⋄ Size←25 125
          Items←#.pdb.puzzleCollection.name
      :EndWith
      puzlCombo.Event←(Select'selectpuzzle&')(Change'changepuzlname&')
     
      collCombo←topline[1].⎕NEW Combo((VScroll ¯1)(Style Drop))
      :With collCombo
          FontObj←'ARIAL' 15 ⋄ Posn←40 0 ⋄ Size←25 125
          Items←#.pdb.(baseCollections,userCollections).name
      :EndWith
      collCombo.Event←⊂(Select'selectcoll&')
     
      boxCombo←topline[2].⎕NEW Combo((VScroll ¯1)(Style DropEdit))
      :With boxCombo
          FontObj←'ARIAL' 15 ⋄ Posn←40 0 ⋄ Size←25 125
          Items←#.pdb.boxDims.name
      :EndWith
      boxCombo.Event←(Select'selectbox&')(Change'changebox&')
     
      :For Cap :In boxvollax piececountlax piecevollax solfoundlax
          Cap.FontObj←'ARIAL' 20 0 ⋄ Cap.Size←25 120 ⋄ Cap.Posn←40 0
      :EndFor
     
      save←topline[0].⎕NEW Button(⊂Style Push)
      backward←topline[3].⎕NEW Button(⊂Style Push)
      forward←topline[3].⎕NEW Button(⊂Style Push)
      fastbackward←topline[2].⎕NEW Button(⊂Style Push)
      fastforward←topline[4].⎕NEW Button(⊂Style Push)
     
      save.Caption←'SAVE' ⋄ save.FontObj←ARIAL 25 ⋄ save.Size←30 125 ⋄ save.Posn←120 0
      save.Event←⊂Select'selectsave&'
     
      :For Cap :In backward fastbackward forward fastforward
          Cap.FontObj←ARIAL 25 ⋄ Cap.Size←30 50 ⋄ Cap.Posn←120 0
      :EndFor
     
      forward.Posn←120 75
      fastbackward.Posn←120 75
     
      (backward fastbackward forward fastforward).Caption←'←' '|←' '→' '→|'
     
      backward.Event←⊂Select'forthandback&' ¯1
      forward.Event←⊂Select'forthandback&' 1
      fastbackward.Event←⊂Select'fastforth&' ¯1
      fastforward.Event←⊂Select'fastforth&' 1
     
    ⍝ firstcolumnsetup  ⍝----------------- First column -------------------------------------
     
      pollab←firstcol[0].⎕NEW Label(⊂Caption'Polyomino')
      idlab←firstcol[1].⎕NEW Label(⊂Caption'Local #')
      voldimlab←firstcol[2].⎕NEW Label(⊂Caption'Vol Dim')
      gidlab←firstcol[3].⎕NEW Label(⊂Caption'Global #')
      pboxlab←firstcol[4].⎕NEW Label(⊂Caption'Envelope Box')
      placbut←firstcol[5].⎕NEW Button(⊂Caption'Placements in box')
      chilab←firstcol[6].⎕NEW Label(⊂Caption'Chiral')
     
      :For Cap :In pollab idlab voldimlab gidlab pboxlab placbut chilab
          Cap.FontObj←ARIAL 20 ⋄ Cap.Size←25 140 ⋄ Cap.Posn←0 10
      :EndFor
     
      placbut.Event←⊂Select'selectplace&'
     
      countlab←firstcol[7].⎕NEW Label(⊂Caption'Count')
      rightlab←firstcol[8].⎕NEW Label(⊂Caption'Right handed')
      leftlab←firstcol[9].⎕NEW Label(⊂Caption'Left handed')
      colorlab←firstcol[10].⎕NEW Label(⊂Caption'Color')
     
      :For Cap :In countlab rightlab leftlab colorlab
          Cap.FontObj←ARIAL 20 ⋄ Cap.Size←25 140 ⋄ Cap.Posn←0 10
      :EndFor
     
    ⍝ tablesetup   ⍝----------------- Table handling -------------------------------------
     
      sections.(label←⎕NEW'Label'(⊂'Caption' 'xxxxxx'))
     
      :For Cap :In sections.label
          Cap.FontObj←ARIAL 20 ⋄ Cap.Size←25 120 ⋄ Cap.Posn←0 10
      :EndFor
     
      ⍝ editsection.(field←⎕NEW Edit(⊂Value'jnh'))
      editsection.(field←⎕NEW'Edit'(⊂'Value' 'jnh'))
     
      :For val :In editsection.field
          val.FontObj←ARIAL 20 ⋄ val.Size←25 120 ⋄ val.Posn←0 0
      :EndFor
     
      editsection[0;].field.Event←⊂¨(⊂Change'setcount&'),¨⍳matrixsize
      editsection[1;].field.Event←⊂¨(⊂Change'setright&'),¨⍳matrixsize
      editsection[2;].field.Event←⊂¨(⊂Change'setleft&'),¨⍳matrixsize
      editsection[3;].field.Event←⊂¨(⊂Change'setcolor&'),¨⍳matrixsize
     
      :For ssf :In matrixsf
          ssf.XRange←3×1 ¯1
          ssf.(YRange←XRange×-Aspect)
          ssf.Event←(MouseEnter'rotate&'ssf)(MouseLeave'stoprot&')(MouseDown'rotate&'ssf)
     
          ssf.selector←ssf.⎕NEW Button(⊂Style Radio)
          ssf.selector.Size←15 15 ⋄ ssf.selector.Posn←0 0 ⋄ ssf.selector.State←0
          ssf.selector.Event←⊂Select'rightleft&'ssf
     
          ssf.leftright←ssf.⎕NEW Label(⊂FieldType'Char')
          ssf.leftright.(Size Posn)←(15 35)(0 88) ⋄ ssf.leftright.(Value Visible)←'Left' 1
      :EndFor
     
      sections.Visible←0
      editsection.Visible←0
      matrixsf.Visible←0
    ∇

    ⍝================================== callbacks =====================================================
    
    ∇ selectcoll;index;voldim;color      ⍝ Select collection
      index←collCombo.(SelItems/⍳⍴SelItems)
      collName voldim color←(index⊃#.pdb.(baseCollections,userCollections)).(name voldimid color)
      collection←(↓voldim){⎕NEW #.polyominod(⍺,⊂⍵)}¨↓color
      mode←'new'
      collectionsetup
    ∇
    
    ∇ selectbox;index     ⍝ Select box
      index←boxCombo.(SelItems/⍳⍴SelItems)
      box←#.pdb.boxDims[index]
      boxdim←⊃box.box
      boxvol←box.volume
      :If box.type≡'Sculpture'
          boxsculp←box.sculpture
      :EndIf
      mode←'new'
      boxsetup
      :If collection≢⍬
          collectionsetup
      :EndIf
    ∇
          
    ∇ selectpuzzle;index;puzl    ⍝ Select puzzle
      index←⊃puzlCombo.(SelItems/⍳⍴SelItems)
      puzl←index⊃#.pdb.puzzleCollection
      puzzlename collName allpieces boxname boxdim←puzl.(name collectionname pieces boxname boxdim)
     
      index←#.pdb.(baseCollections,userCollections).name⍳⊂collName
      voldim color←(index⊃#.pdb.(baseCollections,userCollections)).(voldimid color)
      collection←(↓voldim){⎕NEW #.polyominod(⍺,⊂⍵)}¨↓color
      collCombo.SelItems←index=⍳⍴collCombo.Items
     
      index←#.pdb.boxDims.name⍳⊂boxname
      box←index⊃#.pdb.boxDims
      boxCombo.Text←⍕boxname
     
      mode←'old'
      boxsetup
      collectionsetup
    ∇
    
    ∇ selectsave;pn;pd    ⍝ Select button Save puzzle
      :If 0=+/allpieces.(≢placements)
          allpieces.placement                                    ⍝ forgot to calculate placements
      :ElseIf ∨/allpieces.(0<lefts+rights)
          ((allpieces.(0<lefts+rights))/allpieces).placement     ⍝ ensure chiral sorting has been done
      :EndIf
      pd←⎕NEW puzzle(puzzlename allpieces collName(boxCombo.Text)boxdim)
      #.pdb.puzzleCollection,←pd
      ⎕←'New puzzle 'pd.name
      puzlCombo.Items←#.pdb.puzzleCollection.name
      mode←'new'
    ∇
    
    ∇ selectplace            ⍝ butten Calculate placments
      allpieces.placement
      piecesetup
    ∇
    
    ∇ changebox            ⍝ new boxdim entered
      :If 1<⍴boxCombo.Text
          boxCombo.(Items,⍨←⊂Text)
          boxCombo.(Text←⊃Items)
          boxdim←⍎boxCombo.Text
          box←#.⎕NEW #.polyBox(boxdim)
          #.pdb.boxDims,⍨←box
          mode←'new'
          boxsetup
          :If collection≢⍬
              collectionsetup
          :EndIf
      :EndIf
    ∇
   
    ∇ changepuzlname            ⍝ new save name entered
      :If 1<⍴puzlCombo.Text
          puzzlename←puzlCombo.Text
          mode←'new'
      :EndIf
    ∇
    
    ∇ sign forthandback msg                 ⍝ Back and forth one piece at a time
      firstpiece+←sign
      firstpiece⌈←0
      firstpiece⌊←0⌈piececount-matrixsize
      piecesetup
    ∇
                                            
    ∇ sign fastforth msg;i             ⍝  Back and forth one page at a time
      :For i :In ⍳matrixsize
          firstpiece+←sign
          firstpiece⌈←0
          firstpiece⌊←0⌈piececount-matrixsize
      :EndFor
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
    
    ∇ ssf rightleft msg                     ⍝ Mirror selector
      :Hold 'mirror'
          ssf.piece.(mirror←~mirror)
          ssf.selector.State←ssf.piece.mirror
          ssf.leftright.Value←ssf.piece.mirror⊃'Left' 'Right'
          ssf.poly.mirror
          ssf.poly.draw ssf
      :EndHold
    ∇
    
    ∇ secno setcount msg ⍝ update count field
      pieces[secno].count←0⌈editsection[0;secno].field.Value
      totpiececount←⊃+/allpieces.count
      piecevolume←⊃+/allpieces.(count×vol)
      piecevollax.Caption←⍕piecevolume
      piececountlax.Caption←⍕totpiececount
      pieces[secno].rights←0
      pieces[secno].lefts←0
      piecesetup
    ∇
    
    ∇ secno setright msg ⍝ update count of right handed field
      pieces[secno].rights←pieces[secno].count⌊0⌈editsection[1;secno].field.Value
      pieces[secno].lefts←pieces[secno].(count-rights)
      piecesetup
    ∇
    
    ∇ secno setleft msg ⍝ update count of left handed field
      pieces[secno].lefts←pieces[secno].count⌊0⌈editsection[2;secno].field.Value
      :If 0=pieces[secno].lefts
          pieces[secno].rights←0
      :EndIf
      piecesetup
    ∇
    
    ∇ secno setcolor msg ⍝ update color of piece
      ⍝ pieces[secno].color←pieces[secno].editsection[3;secno].field.Value
      ⍝ piecesetup
    ∇
       
    ∇ stoprot msg
      rotstop←1
    ∇
        
    ⍝=================================== functions ================================================================    
                                                                                                    
 
    ∇ collectionsetup         ⍝ adjust all controls according to the chosen collection
     
      collectionsize←⊃⍴collection
      piececount←⊃⍴collection
      minsize←⊃⌊/collection.vol
      firstpiece←0
      solfound←0  ⍝ ?
      solfoundlax.Caption←⍕solfound
     
      ⍝----------- Navigation buttons -----------------
     
      :If piececount>matrixsize
          (backward fastbackward forward fastforward).Visible←1
      :Else
          (backward fastbackward forward fastforward).Visible←0
      :EndIf
     
      :If piececount<matrixsize
          sections[;piececount↓⍳matrixsize].Visible←0
          editsection[;piececount↓⍳matrixsize].Visible←0
      :Else
          sections.Visible←1
          editsection.Visible←1
      :EndIf
     
      :If mode≡'new'
          allpieces←{⎕NEW piece ⍵}¨(⍳collectionsize){⍺ ⍵}¨collection
      :End
     
      totpiececount←⊃+/allpieces.count
      piecevolume←⊃+/allpieces.(count×vol)
      piecevollax.Caption←⍕piecevolume
      piececountlax.Caption←⍕totpiececount
     
      adrbox←{⍝ Returns the dimensions of the envelope box
          1+⌈⌿⍵
      }
     
      ⍝  matrixsetup
      maxheight←⌈/up adrbox¨collection.polyomino        ⍝ Hight of tallest box
      scalefac←3+0⌈0.25×maxheight-5
      :For ssf :In matrixsf
          ssf.XRange←scalefac×1 ¯1
          ssf.(YRange←XRange×-Aspect)
      :EndFor
     
      piecesetup
    ∇
    
    ∇ boxsetup
      boxvol←box.volume
      boxvollax.Caption←⍕boxvol
    ∇
     
    ∇ piecesetup;ms                 ⍝ Show the visual pieces on screen
      ms←matrixsize⌊piececount
      pieces←ms↑firstpiece↓allpieces
      matrixdraw ms↑firstpiece↓collection               ⍝allpieces pieces.polyd
      sections[;⍳ms].label.Caption←⍉↑pieces.display
      editsection[;⍳ms].field.Value←((-editrows)ms)↑⍉↑pieces.display
      :For val :In editsection
          val.field.Visible←val.field.Value≢'Na'
      :EndFor
    ∇
    
    ∇ matrixdraw polys;ix
      :For ssf ix :InEach matrixsf(⍳⍴matrixsf)
          :If ix<≢polys
              ssf.poly←ix⊃polys
              ssf.poly.draw ssf
              ssf.piece←allpieces[ix+firstpiece]
              ssf.selector.State←ssf.piece.mirror
              ssf.leftright.Value←ssf.piece.mirror⊃'Left' 'Right'
              ssf.leftright.Visible←ssf.piece.chiral
              ssf.Visible←1
          :Else
              ssf.Visible←0
          :EndIf
      :EndFor
    ∇
    
    ⍝---------------- Class puzzle + piece definition ------------------------
    
    :class puzzle    ⍝ 
    :Access Public

        :field Public name
        :field Public pieces
        :field Public collectionname
        :field Public boxdim
        :field Public boxname 
        :field Public date  
        
        ⍝ :include #.polyUtil 
        
        ∇ new(namex piecex pcolname boxnamx bdx)
          :Access Public
          :Implements Constructor 
         
          name←namex
          pieces←piecex
          collectionname←pcolname
          boxdim←bdx
          boxname←boxnamx
          pieces.skiftpolyd2farve
          date←⎕TS
        ∇
        
        ∇ res←allvalues
          :Access Public
         
          res←name pieces collectionname boxdim boxname date
        ∇
        
        ∇ clone frompuzzle
          :Access Public
          :Implements Constructor
         
          name pieces collectionname boxdim boxname date←frompuzzle.allvalues
          pieces←{⎕NEW piece(⍵)}¨frompuzzle.pieces
          date←⎕TS
          ⍝ name←'X',name
        ∇
        
        ∇ dropx
          :Access Public
         
          name←1↓name      ⍝ drop first letter from test
        ∇

    :endClass  
              

    :class piece     ⍝ single piece of the collection
    
        :field Public polyd
        :field Public number←0
        :field Public polyomino 
        :field Public vol
        :field Public dim
        :field Public globalid   
        :field Public count←1
        :field Public rights←0                      ⍝ number of right chiral
        :field Public lefts←0                       ⍝ number of left chiral
        :field Public mirror←0
        :field Public pivot←0
        :field Public placements←⍬ 
        :field Public boxdim
        :field Public ldim  ⍝ lifted  dim 
        :field Public chiral                       ⍝ Indicator for chirality
        
        ⍝ :include #.polyUtil
    
        ∇ new(collindx poly)
          :Access Public
          :Implements Constructor 
         
          boxdim←##.boxdim
          minsize←##.minsize
          box←##.box
          number←collindx
          polyd←poly
          vol dim←polyd.(vol dim)
          globalid←polyd.index
          ldim←≢boxdim               ⍝ lifted  dim or dimension af puzzlebox
          :If dim<4
              polyomino←polyd.polyomino   ⍝ Polyomino is already lifted to 3D
          :Else
              polyomino←⊃globalid pvd vol dim
          :EndIf
          ⍝ placements←0                ⍝ placement polyomino
          :If dim<ldim
              chiral←0
          :Else
              chiral←chirality polyomino     ⍝ ⊃placements
          :EndIf
        ∇

        ∇ res←allvalues
          :Access Public
         
          res←boxdim chiral count dim globalid ldim lefts mirror number pivot placements polyd polyomino rights vol
        ∇
        
        ∇ clone frompiece
          :Access Public
          :Implements Constructor
         
          boxdim chiral count dim globalid ldim lefts←7↑frompiece.allvalues
          mirror number pivot placements polyd polyomino rights vol←7↓frompiece.allvalues
        ∇

        
        ∇ res←farve
          :Access Public
          ⍝ res←polyd.filcol
          res←polyd
        ∇
        
        ∇ skiftpolyd2farve
          :Access Public
          polyd←polyd.filcol
        ∇
        
        ∇ z←display
          :Access Public
         
          z←(⊂⍕number),(⊂⍕vol dim),(⊂⍕globalid),(⊂⍕adrbox polyomino),(⊂⍕⊃≢placements)
          z,←(⊂⍕chiral⊃'No' 'Yes'),(⊂⍕count),(⊂⍕chiral⊃'Na'rights),(⊂⍕chiral⊃'Na'lefts),(⊂'Random')
        ∇

        ∇ placement;perms;leftindicators;leftplacements;rightplacements   ⍝ find all placements of polyomino
          :Access Public 
         
          fixreduct←{⍝ Reduces placements ⍺ for fixed, occupied or illegal place in ⍵
              (⍺{0=≢(↓⍺)∩⍵}¨⊂⍵)/⍺}
         
          perms←ldim⊃#.pdb.allperm
         
          :If ldim>3
              polyomino adrlift⍨←ldim
          :EndIf
         
          placements←naturalorder up casemove¨∘piecemove polyomino   ⍝ Generate Pieceplacements
         
          ⍝ ⎕←'???'chiral lefts rights(≢placements)
         
          :If chiral
          :AndIf 1<≢placements
          :AndIf 0<lefts+rights  ⍝ split into left and right placements
              leftindicators←(⊂0⊃placements){1=⊃¯1↑⍺ #.polyFns.adrdif ⍵}¨placements
              leftplacements←leftindicators/placements
              rightplacements←(~leftindicators)/placements
              ⍝ ⎕←'lr'(≢¨placements leftplacements rightplacements)
              :If lefts=0
                  placements←rightplacements                    ⍝ Throw away leftplacements
              :ElseIf rights=0
                  placements←leftplacements                    ⍝ Throw away rightplacements
              :Else
                  placements←leftplacements,rightplacements     ⍝ assumes equal number of left and right placements
              :EndIf
          :EndIf
         
          :If (⊃box.type)≡'Sculpture'
              placements fixreduct←(,⍳boxdim)~↓⊃box.sculpture
          :EndIf
         
          :If 0=⍴placements
              count←lefts←rights←0
          :EndIf
        ∇
                  
          adrbox←{⍝ Returns the dimensions of the envelope box
              1+⌈⌿⍵
          }

          adrlift←{⍝ Lift polyomino to higher dimension
              ↑(-⍺)↑¨↓⍵
          } 
          
          eqperm←{⍝ permutations of equal elements in a vector
          ,⊃(∘.+)/{(⊂⍵)\¨(⊂⍵/⍳⍴⍵){⍺[⍵]}¨⊃#.pdb.allperm[+/⍵]}¨↓(∪⍵)∘.≡⍵
           }
                       
          adrperm←{⍝ Permutations of order ⍵
              ⍵≤11:⍵⊃#.pdb.allperm
          }
          
          adrorder←{
              ⍵[⍋⍵;⍋⌈⌿⍵]
          }
           
          adrturnit←{
              ⍵[;⍺]
          }
          
          adrmirror←{⍝ Generate all possible mirrorimages
              mirror←{|⍵-(⍴⍵)⍴⍺}         ⍝ Apply mirror ⍺ on polyomino ⍵
              binarymirrors←,⍳(1⊃⍴⍵)⍴2
              mirrors←binarymirrors×⊂(adrbox ⍵)-1
              {⍵[⍋⍵;]}¨mirrors mirror¨⊂⍵
          }
            
          adrtranspose←{⍝ Permutate axis inevery possible way, maintaing roworder
              order←{⍵[⍋⍵;]}
              order¨(eqperm adrbox ⍵)adrturnit¨⊂⍵
          }
                 
        up←⊃,/
         
          caseturn←{⍝ Possible different turns of piececasing
              turns←perms{⍵[⍺]}¨⊂⍵
              perms[turns⍳∪turns]
          }
         
          caseshift←{⍝ Possible shifts (even 0) of piececasing in the box
              caseshifts←∪,⍳0⌈boxdim-(⌈/[0]⍵)-⌊/[0]⍵
              {⍵[⍋⍵;]}∘↑¨⊂[1]caseshifts∘.+⊂[1]⍵
          }
         
          casemove←{⍝ combined movements of piececaseing
              caseturns←caseturn adrbox ⍵
              up caseshift¨caseturns{⍵[;⍺]}¨⊂⍵
          }
                  
          piecemove←{⍝ Move pice around in its casing
              ∪up adrmirror¨∪adrorder¨adrtranspose ⍵
          }
         
          naturalorder←{⍝ order the placements
              ⍵[⍒↑⍵]                                 ⍝ ⍵[⍒↑,∘adr2bitmap¨⍵]
          }
         
          inbox←{ ⍝ Is adress in the box
              ∧/(0≤⍵),⍵<boxdim}
                         
          zchirality←{⍝ Returns 1 if polyomino is chiral else 0
              pm←piecemove ⍵                  ⍝ generate all internal movements
              1=⍴,pm:0                        ⍝ if polyomino is an array then return 0
              ¯1∊up(¯1∘↑)¨2 adrdif/pm         ⍝ Chiral if one negative sign in pairwise transforms
          }
          
          chirality←{⍝ Returns 1 if polyomino is chiral else 0
              mirror←⍵                         ⍝ Make a mirror image of polyomino ⍵
              mirror[;¯1+1⊃⍴⍵]×←¯1             ⍝ Changing sign on last column
              ¯0.5×¯1+4⊃⍵ #.polyFns.adrdif mirror  ⍝ Sign of transformations converted into boolean
          }
             
        up←⊃,/   
                             
    :endClass ⍝-------------- end  piece ---------    
                             
    
:EndClass
