:Class polyLibrary  ⍝ Class polygrid  makes a grid on the shape of polyvoldim = polyomino database

    ⍝ :include  #.polyFns    ⍝Util   xc
     
    ∇ new subform
      :Access Public 
      :Implements Constructor 
     
      GUIsetup subform
    ∇

    ∇ GUIsetup subform;rowno;colno;rowtitles;ma;splittxt;rowtpre
     
      #.polyFns.GUInames
     
      gform←subform #.polyFns.makeformu(10 40 5 40 5)(5 60 5 25 5)
      libsf boxsf cvsf singlesf cvcsf scsf←,gform.subforms[1 3 4;1 3]     ⍝ Subform shorthands
     
      :With Label1←gform.subforms[0;1].⎕NEW 'Label'(⊂'Caption' 'Library') 
          ⍝ Caption  'Library'
          FontObj←'ARIAL' 30 0
          Size←40 120
          Posn←10 400
      :EndWith
       ⍝(⊂'Caption'  Library')
      :With Label2←gform.subforms[0;1].⎕NEW 'Label'(⊂'Caption' 'Volume          Dimension')
          FontObj←'ARIAL' 20 0
          Size←20 300
          Posn←60 0
      :EndWith
                                                ⍝ Windows place on screen
      ⍝ ma←⍴¨#.pdb.polyvoldim
      ma←#.polyDB.pvdx    ⍝count
      rowno colno←15 12
      rowtpre←'Mono- Do- Tro- Tetro- Pento- Hexo- Septo- Octo- 9- 10- 11- 12- 13- 14-'
      splittxt←{(⍵≠' ')⊆⍵}     ⍝ {⎕ML←3 ⋄ (' '≠⍵)⊂⍵}
      rowtitles←(splittxt rowtpre),¨⊂'Mino'
     
      :With Grid1←libsf.⎕NEW 'Grid'(⊂'CellHeights' 21)  ⍝ Grid over polyomino database
          Values←1 ¯3↓ma
          FontObj←'ARIAL' 15
          Size←500 720
          Posn←0 0
          CellWidths←60
          TitleWidth←70
          CellTypes←(rowno colno)⍴1
          ColLineTypes←colno⍴1
          ColTitles←⍕¨⍳colno
          GridLineFCol←0
          GridLineWidth←1
          Input←''
          RowLineTypes←rowno⍴1
          RowTitles←rowtitles
      :EndWith
      Grid1.Event←('CellDown' 'celldown')
    ∇
       
    ∇ celldown msg;rno;cno;count;order;boxes;vol;dim            ⍝ Callback , chosen volume and dimension
     
      :If ⍬≡(⊂msg[6 7])⊃Grid1.Values           ⍝ Empty cases discarded
          :Return
      :EndIf
     
      vol dim←1 0+msg[6 7]
     
      :With Label3←gform.subforms[0;3].⎕NEW 'Label'(⊂'Caption'('Envelope boxes for ',⍕vol dim))
          FontObj←'ARIAL' 20 0
          Size←20 200
          Posn←60 0
      :EndWith
     
      adrbox←{1+⌈⌿⍵}
     
      adrboxgroup←{
          resbox←∪allbox←adrbox¨⍵
          ∪¨(⊂[0]allbox∘.≡resbox[⍋⍋↑resbox])/¨⊂⍵}
     
      boxgroup←adrboxgroup #.polyFns.pvd vol dim          ⍝ ⊃#.polyvoldim[vol;dim]
      boxes←adrbox∘⊃¨boxgroup
      order←⍋↑boxes
      boxes←boxes[order]
      boxesx←boxes
      boxgroup←boxgroup[order]
      count←↑⍴¨boxgroup
     
      :With Grid2←boxsf.⎕NEW 'Grid'(⊂'CellHeights' 21)     ⍝ Grid with box overview
          Values←count
          rno cno←⍴Values
          FontObj←'ARIAL' 15
          Size←400 200
          Posn←0 0
          CellWidths←70
          CellTypes←(rno cno)⍴1
          ColLineTypes←(cno)⍴1
          ColTitles←,⊂'Count'
          TitleWidth←30+8×dim
          GridLineFCol←0
          GridLineWidth←1
          Input←''
          RowLineTypes←rno⍴1
          RowTitles←⍕¨boxes
      :EndWith
      Grid2.Event←('CellDown' 'conveyerstart&')           ⍝ When envelope box is chosen
    ∇
   
    ∇ conveyerstart msg;row;pb;lng;totcount;i;j;cv   ⍝ Callback, Chosen envelope box, Init coveyer belt
      row←msg[6]
     
      :With Label4←gform.subforms[2;1].⎕NEW 'Label'(⊂'Caption' ('Box ',⍕row⊃boxesx))
          FontObj←'ARIAL' 20 0
          Size←20 200
          Posn←25 0
      :EndWith
     
      polyset←⊂row⊃boxgroup
      cv←⎕NEW #.polyConveyer(cvsf polyset ⎕THIS)    ⍝ Create conveyer with contents
    ∇
    
    
       
    ∇ notify(polyominoid fcol);poly;ix                                    ⍝ Notification from conveyer
      :Access Public
     
      polyomino←polyominoid⊃⊃polyset
     
      :With Label5←gform.subforms[2;3].⎕NEW 'Label'(⊂'Caption' ('# ',⍕polyominoid))
          FontObj←'ARIAL' 20 0
          Size←20 100
          Posn←25 0
      :EndWith
     
      sp←⎕NEW #.polyPane(singlesf(polyomino fcol))    ⍝ The lower right singles pane
     
    ∇
:endClass
