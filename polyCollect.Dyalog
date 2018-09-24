:Class polyCollect  ⍝ Browse the library and make a collection xx
  
    :field Public selection    ⍝ Collection of polyominod's
    :field Public vol 
    :field Public dim    
    :field Public finished←0   
   
    :include #.polyFns

    ∇ new subform
      :Access Public 
      :Implements Constructor  
     
      vol dim←5 3
      pvdvoldim← pvd vol dim
      guisetup subform
      selection←⍬
      boxsetup
    ∇
    
      ⍝----------- defining GUI Forms and subform -----------------------------   

    ∇ guisetup subform
     
      GUInames       ⍝ GUI selfies
     
      gform←subform makeformu(5,16⍴11 1)(3,(15⍴11 1),3)
      matrixsf←gform.subforms[1+2×⍳8;1+2×⍳8]
      topline←,gform.subforms[0;1+2×⍳8]
      matrixsize←64
     
      sellab←topline[0].⎕NEW Label(⊂Caption'Selection Page:')
      boxlab←topline[1].⎕NEW Label(⊂Caption'Box:')
      sizelab←topline[2].⎕NEW Label(⊂Caption'Size:')
      fromtolab←topline[3].⎕NEW Label(⊂'Caption' 'FromTo:')
      pagelab←topline[4].⎕NEW Label(⊂Caption'Page:')
      backward←topline[5].⎕NEW Button(⊂Style Push)
      forward←topline[5].⎕NEW Button(⊂Style'Push')
      fastbackward←topline[6].⎕NEW Button(⊂Style Push)
      fastforward←topline[6].⎕NEW Button(⊂Style Push)
      save←topline[6].⎕NEW Button(⊂Style Push)
      collab←topline[2].⎕NEW Label(⊂Caption'Predef. Coll:')
      savlab←topline[4].⎕NEW Label(⊂Caption'Save as:')
      colsizelab←topline[1].⎕NEW Label(⊂Caption'Coll size: 0')
      toselected←topline[7].⎕NEW Button(⊂Style Push)
      back←topline[7].⎕NEW Button(⊂Style Push)
      save.Caption←'Save'
     
      :For Cap :In sellab pagelab boxlab fromtolab toselected sizelab savlab collab colsizelab back
          Cap.FontObj←'ARIAL' 21 0 ⋄ Cap.Size←30 130 ⋄ Cap.Posn←10 0
      :EndFor
     
      :For Cap :In backward fastbackward forward fastforward save
          Cap.FontObj←'ARIAL' 20 0 ⋄ Cap.Size←30 50 ⋄ Cap.Posn←10 0
      :EndFor
     
      ⍝ vollab.Caption←'Vol: ',(⍕vol),' Dim: ',⍕dim
     
      secCombo←topline[0].⎕NEW Combo((VScroll ¯1)(Style'Drop'))
      :With secCombo
          FontObj←'ARIAL' 20
          Posn←10 0
          Size←25 130
          items←∪,(⍳12)∘.{⍺>⍵:⍺ ⍵ ⋄ 1 0}1+⍳3
          Items←{'Vol: ',(⍕⊃⍵),' Dim: ',⍕1⊃⍵}¨items
      :EndWith
      secCombo.Event←⊂(Select'selectsec&')
     
      collCombo←topline[3].⎕NEW Combo((VScroll ¯1)(Style'Drop'))
      :With collCombo
          FontObj←'ARIAL' 20
          Posn←10 0
          Size←25 130
          Items←(#.pdb.baseCollections,#.pdb.userCollections).name,'Sporadic' 'Clear selection'
      :EndWith
      collCombo.Event←⊂(Select'selectcoll&')
     
      saveCombo←topline[5].⎕NEW Combo((VScroll ¯1)(Style'DropEdit'))
      :With saveCombo
          FontObj←'ARIAL' 20
          Posn←10 0
          Size←25 130
          Items←#.pdb.userCollections.name
      :EndWith
      saveCombo.Event←(Select'selectsavename&')(Change'changesavename&')  ⍝ ('KeyPress' 'keysave&')
     
      toselected.Caption←'→Selected'
      back.Caption←'→Back'
      forward.Posn←10 70
      fastforward.Posn←10 70
      save.Posn←10 35
     
      backward.Event←⊂Select'forthandback&' ¯1
      forward.Event←⊂Select'forthandback&' 1
      fastbackward.Event←⊂Select'fastforth&' ¯1
      fastforward.Event←⊂Select'fastforth&' 1
      toselected.Event←⊂Select'selectsetup&'
      back.Event←⊂Select'selectback&'
      save.Event←⊂Select'selectsave&'
     
      visibility 0
    ∇
    
    ⍝------------- Selecting the polyominoes and order in groups after box shape -------

    ∇ boxsetup 
      ⍝ pvdvoldim← pvd vol dim
      boxgroups←adrbox eqc pvdvoldim
      boxorder←⍋boxes←↑adrbox∘⊃¨boxgroups
      boxgroupsindex←(⊂pvdvoldim)⍳¨boxgroups    ⍝ bring boxgroups on index form
      boxgroupsindex←boxgroupsindex[boxorder]
      boxes←↓boxes[boxorder;]
      pagedescriptors
      matrixsetup
      pagesetup
    ∇
     
      adrbox←{
          1+⌈⌿⍵
      }

    ⍝--------------------- Handling the matrix page ---------------------------------

    ∇ pagesetup;groupno;pageix;from;to;polys;box;groupsize;grouppagecount;gb;polysels
      groupno pageix from to polys←page⊃pages       ⍝  polysels
      groupno box groupsize grouppagecount←groupno⊃boxgroupdescriptors
     
      totcount←#.polyDB.pvdcount[vol;dim]    ⍝ ⊃⍴pvd vol dim    ⍝ ⊃#.polyvoldim[vol;dim]
      pagelab.Caption←'P. ',(⍕page),' /',⍕maxpage
      sizelab.Caption←'# ',(⍕groupsize),' /',⍕totcount
      boxlab.Caption←'Box:',(2 0)⍕box
      fromtolab.Caption←'No: ',(⍕from),'-',⍕to
      (backward forward).Caption←('←X'[page=0])('→X'[page=maxpage])
      (fastbackward fastforward).Caption←'|',¨(backward forward).Caption
     
      :If polys≡⍬
          gb←(groupno⊃boxgroupsindex)[from+⍳1+to-from]
          polys←{⎕NEW #.polyominod(vol dim ⍵)}¨gb
          (page⊃pages)[4]←⊂polys
      :EndIf
     
      matrixdraw polys
    ∇
    
    ∇ selectsetup;ssf;ix;polys    ⍝ The selection page
      selection←∪selection
      :If 0<⍴selection
          colsizelab.Caption←'Nu: ',(⍕⊃⍴selection),' Vo: ',(⍕⊃+/selection.vol)
          selection.selected←1
      :Else
          colsizelab.Caption←'Coll size: 0'
      :EndIf
      matrixdraw selection
      visibility 1                                              ⍝ final tutch
    ∇
    
    ∇ matrixdraw polys;ix
      :For ssf ix :InEach (,matrixsf)(⍳matrixsize)
          :If ix<≢polys
              ssf.poly←ix⊃polys
              ssf.poly.draw ssf
              ssf.(selector.State←poly.selected)
              ssf.Visible←1
          :Else
              ssf.Visible←0
          :EndIf
      :EndFor
      rotstop←1
    ∇
    
    ∇ visibility page ⍝ Shifts the visibility. page is 0 or 1
      (secCombo pagelab boxlab fromtolab sizelab toselected).Visible←~page
      (backward forward fastbackward fastforward).Visible←~page
      (sellab collCombo collab colsizelab savlab saveCombo save back).Visible←page
    ∇
    
⍝------------------------- Inittialization details ------------------------------ 
   
    ∇ pagedescriptors
     
      describe←{
          groupsize←≢⍵
          box←adrbox (⊃⍵)⊃pvdvoldim    ⍝ pvd vol dim
          groupno←boxes⍳⊂box
          grouppagecount←⌈groupsize÷matrixsize
          groupno box groupsize grouppagecount
      }
     
      pageelements←{
          groupno box groupsize grouppagecount←⍵
          pageelm←{
              pageix←⍵
              from←pageix×matrixsize
              to←(groupsize⌊from+matrixsize)-1
              polys←⍬
              groupno pageix from to polys
          }
          pageelm¨⍳grouppagecount
      }
     
      boxgroupdescriptors←describe¨boxgroupsindex
      pages←⊃,/pageelements¨boxgroupdescriptors
     
      page←0
      maxpage←¯1+⊃⍴pages
    ∇
      
    ∇ matrixsetup;maxheight;scalefac
      maxheight←⌈/⊃,/(¯1∘↑)∘(1∘⊃)¨boxgroupdescriptors       ⍝ Hight of tallest box
      scalefac←3+0⌈0.25×maxheight-5
     
      :For ssf :In matrixsf
          ssf.XRange←scalefac×1 ¯1
          ssf.(YRange←XRange×-Aspect)
          ssf.Event←(MouseEnter'rotate&'ssf)(MouseLeave'stoprot&')(MouseDown'rotate&'ssf)
          ssf.selector←ssf.⎕NEW Button(⊂Style Radio)
          ssf.selector.Size←15 15 ⋄ ssf.selector.Posn←0 0 ⋄ ssf.selector.State←0
          ssf.selector.Event←⊂Select'selected&'ssf
      :EndFor
    ∇
       
   ⍝----------------------- Callbacks ------------------------------------------------------- 

    ∇ sign forthandback msg                 ⍝ Back and forth one page a time
      page+←sign
      page⌈←0
      page⌊←maxpage
      pagesetup
    ∇
    
    ∇ sign fastforth msg;pageix             ⍝ Jumping to box start page
      :Repeat
          page+←sign
          page⌈←0
          page⌊←maxpage
          pageix←1⊃page⊃pages
      :Until (pageix=0)∨page=maxpage
      pagesetup
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
    
    ∇ selectsec    ⍝ when new contents from library
      vol dim←⊃secCombo.(SelItems/items)     ⍝ vol dim←⍎⊃secCombo.(SelItems/Items)
      ⍝ vollab.Caption←'Vol: ',(⍕vol),' Dim: ',⍕dim
      pvdvoldim← pvd vol dim
      boxsetup
      visibility 0
    ∇
    
    ∇ selectcoll;idp;col;vol;dim;id;collax;polyds    ⍝ Selects a collection from basecollections.
      collax←⊃collCombo.SelItems/(#.pdb.baseCollections,#.pdb.userCollections).name,'Sporadic' 'Clear selection'
      :If collax≡'Clear selection'
          selection←⍬
      :ElseIf collax≡'Sporadic'
          polyds←{⎕NEW #.polyominod(,⊂⍵)}¨#.pdb.sporadicPieces.polyomino
          polyds.index←#.pdb.sporadicPieces.number
          selection,←polyds
      :Else
          idp col←↓¨⊃⊃((¯2↓collCombo.SelItems)/#.pdb.baseCollections,#.pdb.userCollections).(⊂voldimid color)
          selection,←idp{⎕NEW #.polyominod(⍺,⊂⍵)}¨col
      :EndIf
      selectsetup
    ∇
        
    ∇ selectsave;sn;ix;size
      sn←saveCombo.Text      ⍝ (SelItems/Items)
      ix←#.pdb.userCollections.name⍳⊂sn
      size←≢#.pdb.userCollections
      :If ix=size
          #.pdb.userCollections,←#.⎕NEW #.polyCollection(sn selection ⍬)      ⍝ New
          collCombo.Items←(#.pdb.baseCollections,#.pdb.userCollections).name,'Sporadic' 'Clear selection'
      :Else
          #.pdb.userCollections[ix]←#.⎕NEW #.polyCollection(sn selection ⍬)   ⍝ Replace
      :EndIf
     ⍝ ⎕←'Save 'sn ix size
    ∇
    
    ∇ selectsavename;sn
      sn←saveCombo.(SelItems/Items)
    ∇
    
    ∇ changesavename            ⍝ new save name entered
      :If 1<⍴saveCombo.Text
          saveCombo.(Items,⍨←⊂Text)
          saveCombo.(Text←⊃Items)
      :EndIf
    ∇
      
    ∇ selectback msg                               ⍝ Going back to main page
      visibility 0
      pagesetup
    ∇

    ∇ ssf selected msg                        ⍝ Handling the select control
      :Hold 'selector'
          ssf.poly.(selected←~selected)
          :If ssf.poly.selected
              selection,←ssf.poly
          :Else
              selection~←ssf.poly
          :EndIf
          ssf.selector.State←ssf.poly.selected
      :EndHold
    ∇

:endClass
