:Class polyGenerate       ⍝  Polyomino application start page

    :field public graf
                      
    :include #.polyFns
    
    ∇ new subform
      :Access Public 
      :Implements Constructor 
     
      guisetup subform
    ∇
    
    ∇ guisetup subform;ix;cap
     
      GUInames
     
      mainform←subform makeformu(11 30 2 55 2)(2 40 2 54 2)      ⍝ Definiton of main page subform layout
     
      headlf←mainform.subforms[0;1]
      console graf vars boxstat←,mainform.subforms[1 3;1 3]
     
      phase←0
     
      :With headline←headlf.⎕NEW Label(⊂Caption'Generator')
          FontObj←'ARIAL' 30 ⋄ Size←30 220 ⋄ Posn←5 0
      :EndWith
     
      :With voldimlab←console.⎕NEW Label(⊂Caption'Volume and Dimension')
          FontObj←'ARIAL' 25 ⋄ Size←20 300 ⋄ Posn←20 0 ⋄ Visible←1
      :EndWith
     
      :With candilab←console.⎕NEW Label(⊂Caption'xxx')
          FontObj←'ARIAL' 25 ⋄ Size←20 300 ⋄ Posn←50 0 ⋄ Visible←0
      :EndWith
     
      :With startlab←console.⎕NEW Label(⊂Caption'xxx')
          FontObj←'ARIAL' 25 ⋄ Size←20 300 ⋄ Posn←80 0 ⋄ Visible←0
      :EndWith
     
      :With nextlab←console.⎕NEW Label(⊂Caption'Find candidates')
          FontObj←'ARIAL' 25 ⋄ Size←20 220 ⋄ Posn←50 130
      :EndWith
     
      :With voledit←console.⎕NEW Edit(⊂Value'10')
          FontObj←'ARIAL' 20 ⋄ Size←25 60 ⋄ Posn←20 230 ⍝
      :EndWith
     
      :With dimedit←console.⎕NEW Edit(⊂Value'7')
          FontObj←'ARIAL' 20 ⋄ Size←25 60 ⋄ Posn←20 300 ⍝
      :EndWith
      (voledit dimedit).Event←(⊂Change'changevoldim&')
     
      :With next←console.⎕NEW Button(⊂Style Push)
          Caption←'Next' ⋄ FontObj←'ARIAL' 25 ⋄ Size←25 120 ⋄ Posn←50 0
      :EndWith
      next.Event←⊂Select'selectnext&'
     
      cap←txtsplit'Time Dur Progress Remaining Totfound EstimTot EstimFin Gauge GageAcu StepDur'
     
      varname←varvalue←⍬
     
      :For ix :In ⍳⍴cap
          varname,←vars.⎕NEW Label(⊂Caption'jnh')
          :With varname[ix]
              FontObj←'ARIAL' 20 ⋄ Size←20 100 ⋄ Posn←(30×ix)0 ⋄ Visible←1
          :EndWith
     
          varvalue,←⊂vars.⎕NEW Label(⊂Caption'val') ⍝ (⍕ix))
          :With varvalue[ix]
              FontObj←'ARIAL' 20 ⋄ Size←20 400 ⋄ Posn←(30×ix)110 ⋄ Visible←1
          :EndWith
      :EndFor
     
      varname.Caption←cap
      varvalue.Caption←⍕¨⍳⍴cap
     
      :With boxgrid←boxstat.⎕NEW Grid(⊂CellHeights 21)
          Values←5 7⍴0
          Size←##.Size
          Posn←0 0
          CellWidths←100 80 80 80 80 80 80
          TitleWidth←50
          ColTitles←'Box' '# Candis' '# Found' 'Acpt pct.' 'Time' 'Can/sec' 'Found/sec'
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
     
    ∇
    
    ∇ runwizard
     
     ⍝ ⎕←'wizard 'phase
     
      :If phase=1
          vol←voledit.Value
          dim←dimedit.Value
          stdcubes←↓¨dim⊃#.polyDB.stdcubes
          boxshapes←↓vol genbox dim
          xtroot←0⊃#.pdb.roots      ⍝ 'Y:\Documents\jnhshared\xt\'
          directory←,'G⊂v99d99⊃'⎕FMT 100 1+.×vol dim      ⍝ Supposed to exist
          path←xtroot,directory,'\'
          bigmode←vol>10
         ⍝ next.Posn+←30 0
         ⍝ nextlab.Posn+←30 0
      :ElseIf phase=2
          totstart←dursec 0
          findcandidates
          nextlab.Caption←'Reduce candidates'
          candilab.Caption←'Candidates: ',⍕nototcandis
          candilab.Visible←1
      :ElseIf phase=3
          from←0
          nextlab.Caption←'Stop / Pause '
          startlab.Caption←'Started: ',⍕6↑⎕TS
          startlab.Visible←1
          reducestart←dursec 0
          reducecandidates
          ⍝ ⎕←'cleanup and save'
      :Else
          ⍝ from←x
          ⍝ reducecandidates
      :EndIf
    ∇
     
   ⍝---------- Find the candidates -----------------------
   
    ∇ findcandidates
     
      :If bigmode=0    ⍝ Small
     
          dcandi←⊃,/extendim¨pvd vol dim-1       ⍝ ⊃#.polyvoldim[vol-1;dim-1]
          vdcandi←⊃,/extenvol¨pvd(vol-1)dim     ⍝ ⊃#.polyvoldim[vol-1;dim]
          allcandis←∪¨adrbox eqc dcandi,vdcandi
          allcandis←allcandis[⍋↑(adrbox∘⊃)¨allcandis]    ⍝ Sort in boxorder
          boxcandis←↑(⊂'ALL' 0 0 0 0),{(adrbox⊃⍵)(≢⍵)(0)(0)(0)}¨allcandis
          boxcandis[0;1]←⊃+/boxcandis[;1]
          boxgrid.Values←boxcandis
          nototcandis←boxcandis[0;1]
     
      :ElseIf vol=11
          ⎕CMD'mkdir ',path
     
          dcandi←∪¨adrbox eqc⊃,/extendim¨pvd vol dim-1 ⍝ ⊃#.polyvoldim[vol-1;dim-1]
          dboxes←adrbox∘⊃¨dcandi
          dsizes←≢∘⊃¨dcandi
          dcandi,←⊂⍬
     
          vcandi←∪¨adrbox eqc⊃,/extenvol¨pvd(vol-1)dim  ⍝ ⊃#.polyvoldim[vol-1;dim]
          vboxes←adrbox∘⊃¨vcandi
          vsizes←≢∘⊃¨vcandi
          vcandi,←⊂⍬
     
          xtdistrib←{⍝ combines the 2 candigroups, and put onto external variables on disc
              filename←path,'box','0123456789ABCDEFGHIJ'[⍵],'c'
              size←filename setxtvalue∪(⊃dcandi[dboxes⍳⊂⍵]),⊃vcandi[vboxes⍳⊂⍵]
              (⍵)(size)(filename)
          }
          boxcandis←↑xtdistrib¨boxshapes
          boxcandis←↑(⊂'ALL' 0 0 0 0 0),{(0⊃⍵)(1⊃⍵)(0)(0)(0)(0)(0)(2⊃⍵)}¨↓boxcandis
          boxcandis[0;1]←⊃+/boxcandis[;1]
          boxgrid.Values←boxcandis[;⍳7]
          nototcandis←boxcandis[0;1]
          vcandi←dcandi←⍬
      :ElseIf vol>11
         ⍝
⍝          ⎕CMD'mkdir ',path
⍝
⍝          dcandi←∪¨adrbox eqc⊃,/extendim¨pvd vol dim-1 ⍝ ⊃#.polyvoldim[vol-1;dim-1]
⍝          dboxes←adrbox∘⊃¨dcandi
⍝          dsizes←≢∘⊃¨dcandi
⍝          dcandi,←⊂⍬
⍝
⍝          vcandi←∪¨adrbox eqc⊃,/extenvol¨pvd(vol-1)dim  ⍝ ⊃#.polyvoldim[vol-1;dim]
⍝          vboxes←adrbox∘⊃¨vcandi
⍝          vsizes←≢∘⊃¨vcandi
⍝          vcandi,←⊂⍬
⍝
⍝          xtdistrib←{⍝ combines the 2 candigroups, and put onto external variables on disc
⍝              filename←path,'box','0123456789ABCDEFGHIJ'[⍵],'c'
⍝              size←filename setxtvalue∪(⊃dcandi[dboxes⍳⊂⍵]),⊃vcandi[vboxes⍳⊂⍵]
⍝              (⍵)(size)(filename)
⍝          }
⍝          boxcandis←↑xtdistrib¨boxshapes
⍝          boxcandis←↑(⊂'ALL' 0 0 0 0 0),{(0⊃⍵)(1⊃⍵)(0)(0)(0)(0)(0)(2⊃⍵)}¨↓boxcandis
⍝          boxcandis[0;1]←⊃+/boxcandis[;1]
⍝          boxgrid.Values←boxcandis[;⍳7]
⍝          nototcandis←boxcandis[0;1]
⍝          vcandi←dcandi←⍬
     
     
     
     
     
     
         ⍝  ⎕←('OK')(⎕WA)(⎕TS)(⍴dcandi)(⍴vdcandi)
      :EndIf
    ∇
             
    ⍝--------------- Reduce the candidates --------------------
       
    ∇ reducecandidates
     
      acugauge←5⍴0
      gauge←5⍴0
      g←{gauge[⍺]+←≢⍵ ⋄ ⍵}
     
      acres←⍬
      stop←0
      noremcandis←¯1
      sampler&1
      refresh&5     ⍝00
     
      :If bigmode=0
          :For ix :In ¯1+≢boxcandis
              start←dursec 0
              gaugecan←⍬
              acres,←⊂res←⊃,/(3∘g)∘eqparty¨(2∘g)signatureq(1∘g)(ix-1)⊃allcandis
              dur←dursec start
              boxcandis[0;2 4]+←boxcandis[ix;2 4]←(≢res)(round1 dur)
              boxcandis[ix;3]←round1 100×⊃÷/boxcandis[ix;2 1]
              boxcandis[0;3]←round1 100×⊃÷/boxcandis[0;2 1]
              ⍝ boxgrid.Values←boxcandis
     
              2 3 4{⎕NQ'boxgrid'CellChange 0 ⍺(⍵)}¨boxcandis[0;2 3 4]
              2 3 4{⎕NQ'boxgrid'CellChange ix ⍺(⍵)}¨boxcandis[ix;2 3 4]
          :EndFor
      :Else
          :For ix :In from↓1+⍳¯1+≢boxcandis
              start←dursec 0
              gaugecan←⍬
              filename←⊃boxcandis[ix;7]
              res←⊃,/(3∘g)∘eqparty¨(2∘g)signatureq(1∘g)getxtvalue filename
              str←(¯1↓filename)setxtvalue↑⊃¨res
              dur←dursec start
     
              boxcandis[0;2 4]+←boxcandis[ix;2 4]←(≢res)(round1 dur)
              boxcandis[ix;3]←round1 100×⊃÷/boxcandis[ix;2 1]
              boxcandis[0;3]←round1 100×⊃÷/boxcandis[0;2 1]
              :If boxcandis[ix;4]>0.1
                  boxcandis[ix;5]←round1⊃÷/boxcandis[ix;1 4]
                  boxcandis[ix;6]←round1⊃÷/boxcandis[ix;2 4]
                  boxcandis[0;5]←round1⊃÷/boxcandis[0;1 4]
                  boxcandis[0;6]←round1⊃÷/boxcandis[0;2 4]
              :EndIf
              boxgrid.Values←boxcandis[;⍳7]
     
              acugauge+←gauge
              gauge←5⍴0
     
              durtot←dursec totstart
              nousedcandis nototfound←acugauge[1 3]
              noremcandis←nototcandis-nousedcandis
              progress←round1 100×(1-noremcandis÷nototcandis)
              totestimate←100×nototfound÷1⌈progress
              timerem←1000 24 60 60⊤0⌈(100×boxcandis[0;4]÷1⌈progress)
     
              varvalue[⍳5].Caption←⍕¨(6↑⎕TS)(⌊durtot)progress noremcandis nototfound
              varvalue[5 6].Caption←0⍕¨totestimate timerem
              res←0
              :If stop ⋄ :Leave ⋄ :EndIf
          :EndFor
          stop←1
          ⎕←'Slut '⎕TS(round1 durtot÷3600)
     
      :EndIf
    ∇
    
    
    ⍝--------------- Utility functions ----------------

    ∇ z←getxtvalue filename;temp
      filename ⎕XT'temp'
      z←temp
      ''⎕XT'temp'
    ∇
     
    ∇ z←filename setxtvalue ary;temp
      filename ⎕XT'temp'
      z←≢temp←ary
      ''⎕XT'temp'
    ∇
    
      txtsplit←{⍝ Split a text at blanks
          ⎕ML←3 ⋄ (' '≠⍵)⊂⍵
      }
       
      dursec←{⍝ duration mean
          ⍵≡0:⎕TS
          0 0 86400 3600 60 1 0.001+.×⎕TS-⍵
      }
   
      round←{⍝ Round ⍵ to ⍺ decimal places
          ⍺←0
          ⍺=0:⌊0.5+⍵                   ⍝ Integer round
          ⍺=1:(⌊0.5+10×⍵)÷10           ⍝ One decinal round
          n←10*⍺
          (⌊0.5+n×⍵)÷n                 ⍝ ⍺ decinal round
      }
           
      adrbox←{⍝ Returns the dimensions of the envelope box
          1+⌈⌿⍵
      }
      
      eqc←{⍝ Equivalence clases of ⍺⍺ on ⍵. Like ⍺⍺⍣-1 ⍵
          ⍬≡⍴⍵:⊂,⍵
          (,1)≡⍴⍵:⊂⍵
          a←⍺⍺¨b←,⍵
          res←⍬
          eqpartx←{⍝ Partitionates a vector v by in groups by ≡.
              0=⍴,⍵:⍬
              bool←a[1↑⍵]≡¨a[⍵]
              res,←⊂b[bool/⍵]                ⍝ Result as sideeffect
              (⍺-1)eqpartx(~bool)/⍵
          }
          s←(⍴⍵)eqpartx⍳⍴⍵                   ⍝ Using indexes for efficiency
          res
      }
           
      signatureq←{ ⍝ Combine signatures for splitting a group polyominoes
          gc←{gaugecan,←≢⍵ ⋄ ⍵}
     
          part←{⊃,/(⍺⍺ eqc)¨gc ⍵}
     
          cubepart←{
              split←((5⍴0),(100 50 100 100000000),(10⍴100000000))[dim]       ⍝ dim  5 6 7 8
              split=100000000:gc ⍵
              1=≢⍵:gc ⍵
              shapes←⊃,/⍴¨⍵
              sortgroups←⍵[⍋shapes]
              cut←+/shapes<split
              cut=⍴shapes:gc sortgroups
              (gc cut↑sortgroups),(cubesignature part cut↓sortgroups)
          }
     
          gc cubepart(distsignature part)(orbitsignature part)(nabosignature part)⊂⍵
      }
       
      eqparty←{⍝ Equivalence clases of geometric congruent polyominoes in ⍵, using indexes.
          a←⍵
          res←⍬
          eqpartx←{⍝ Partitionates a vector in groups by eqpoly.
              0=⍴⍵:⍬                         ⍝ Stopping recursion
              1=⍴⍵:res,←⊂a[⍵]                ⍝ Assuming reflecsivity
              bool←compare a[⍵]              ⍝ Compare first element to each of rest
              res,←⊂a[bool/⍵]                ⍝ Result as sideeffect
              eqpartx(~bool)/⍵               ⍝ Recursive call to rest
          }
          s←eqpartx⍳⍴⍵                       ⍝ Using indexes for efficiency
          res
      }
     
      compare←{⍝ Compare first element to rest of a vector of polyominoes
     
          ac←naboorden∘adr2origo⊃⍵
          an←↓nabodist ac
          ainv←⌹ac                                      ⍝ Generalized inverse of ac
     
          comparetoa←{⍝ Compare ⍵ to a
     
              bc←naboorden∘adr2origo ⍵                   ⍝ Order rows and move to origo.
              ac≡bc:(dim dim)⍴1,dim⍴0                    ⍝ If identical return unity matrix
              bn←↓nabodist bc                            ⍝ Count neighbours
              an≢bn:⍬                                    ⍝ Nabodist must be identical
              eqbc←(eqperm an⍳bn)rowperm bc              ⍝ Permutate rows that conserve nabodist
     
              findcandi←{                                   ⍝ Test candidates until one found
                  res←round1 ainv+.×⍵⊃eqbc                  ⍝ Solve eqation
                  notfound←~iscandidate res                 ⍝ The matrix is not of proper type
                  notfound∨←~(ac+.×res)eqrows bc            ⍝ or Test of found transformation fail
                  notfound∧0<⍵:findcandi ⍵-1                ⍝ If not ok continue by recursion
                  notfound:⍬                                ⍝ No proper transformation found at all
                  res                                       ⍝ Return verified result
              }
              findcandi ¯1+⍴eqbc
          }
          1,iscandidate∘comparetoa¨1↓⍵                 ⍝ the first element is identival to itself
      }
                                                                                   
      iscandidate←{⍝ Is matrix of 0, 1 and ¯1, with one nonzero in each row and col
          ~∧/(,⍵)∊¯1 0 1:0                 ⍝ ∊¨⊂¯1 0 1:0
          ~∧/1=+/|⍵:0
          ∧/1=+⌿|⍵
      }
      
      orbitsignature←{⍝ finds orbital signature of a piece
          +/¨(⊂↓⍵)∊¨↓¨orbits adrbox ⍵
      }
 
      orbits←{⍝ finds the orbital constituents of a box
          box←⍵[⍋⍵]                                    ⍝ parameter is the shape of the box
          boxcenter←⊂¯0.5+0.5×box
          ↑¨(⊂boxcenter)+{⊃+/⍵*2}eqc(,⍳box)-boxcenter  ⍝ Groups of cells with same dist from boxcenter
      }
        
      nabosignature←{ ⍝ Optæller forgrenings typer
          convert∘nabocount ⍵
      }
      
      distsignature←{ ⍝ Signature based on sorted internal dist
          rowsort(0 2)↓nabodist ⍵
      }
      
      cubesignature←{ ⍝ Signature that count subcubes of a polyomino=⍵
          gauge[0]+←1
          (1 ¯1)↓⍉↑countparts¨⍪/stdcubes∘.+⊂¨↓2×⍵
      }

      countparts←{
          firsts←2≢/⍵[⍋↑⍵]                          ⍝ unik firstmarks of ordered rows
          freq←-2-/(1,firsts,1)/⍳2+⍴firsts          ⍝ dist between firsts is freq
          cm←(1+⌈/freq)⍴0
          cm[freq]+←1
          cm
      }
      
      genbox←{⍝ generates all valid boxes for polyominoes of volume ⍺ and dimension ⍵
     
          vol dim←⍺ ⍵
          deltas←↓(⍳dim)∘.=⍳dim
          maxdim←vol+dim-1
     
          genit←{
              ~∧/2≤/⍵:⍬                                ⍝ not monoton
              maxdim<+/⍵:⍬                             ⍝ to big dimension
              vol>×/⍵:⊃,/∇¨deltas∘.+⊂⍵                 ⍝ to little volumen, try bigger boxes
              ∪(⊂⍵),⊃,/∇¨deltas∘.+⊂⍵                   ⍝ ok box, try also bigger boxes
          }
     
          {⍵[⍋⍵;]}↑∪genit dim⍴2
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
      
      adr2origo←{⍝ moves a polyomino so center of box coincides origo
          ⍵-[1]((⌈⌿⍵)+⌊⌿⍵)÷2
      }
      
      polynormal←{⍝ moves polyomino so lower left corner has coordinates 0 0 0 ..
          ⍵-[1]⌊⌿⍵           ⍝  ⍵-(⍴⍵)⍴⌊⌿⍵
      }
          
      eqrows←{⍝ Tells if 2 polyominoes have same rows, but maybe in a different order
          (⍴⍺)≢⍴⍵:0
          0<⍴(↓⍺)~↓⍵:0
          0=⍴(↓⍵)~↓⍺
      }
      
      extenvol←{ ⍝ Extension of volume with same dimension (vertical case)
          0=⍴,⍵:⍬
          cord←↓⍵
          dp←dp,-dp←↓(⍳dim)∘.=⍳dim
          halo←⊂¨(∪,dp∘.+cord)~cord
          rowsort∘colsort∘polynormal¨↑¨halo,¨⊂cord
      }
     
      extendim←{ ⍝ Extension of volume and dimension (diagonal case)
          rowsort∘colsort∘polynormal¨(⊂1,⍵)⍪¨↓0,⍵
      }

      rowsort←{⍝ Sort rows in a matrix
          ⍵[⍋⍵;]
      }
      
      colsort←{⍝ Sort colmns after maximum values
          ⍵[;⍋⌈⌿⍵]
      }
        
      convert←{⍝ Count indexes
          a←(⍴⍵)⍴0
          a[⍵]+←1
          a
      }
      
      round1←{⍝ Round ⍵ to 1 decimal place
          (⌊0.5+10×⍵)÷10
      }
 
   ⍝   rowperm←{⍝ Permutates rows in a 2D matrix in every or ⍺ possible way
⍝          ⍺←adrperm⊃⍴⍵                    ⍝ If no ⍺ , insert all permutations
⍝          ⍺{⍵[⍺;]}¨⊂⍵
⍝      }
   ⍝    
⍝      adrperm←{⍝ Permutations of order ⍵
⍝          ⍵≤11:↓⍵⊃#.permutations
⍝      }
⍝      
⍝      eqperm←{⍝ permutations of equal elements in a vector
⍝          ,⊃(∘.+)/{(⊂⍵)\¨(⊂⍵/⍳⍴⍵){⍺[⍵]}¨⊃#.pdb.allperm[+/⍵]}¨↓(∪⍵)∘.≡⍵
⍝      }
         
⍝---------------------------- monitoring and sampling functions -----------------------------------
   
        
    ∇ sampler delay ⍝ Sampler reads the gauges once every minute and makes a graph
      :Access Public 
     
      ⍝ nototcandis←⊃+/startfrom↓,boxcandis[;1]        ⍝ nototgroups←gauge[1 2]
      noremcandis←nototcandis
     
      monitor←(1000 4)⍴0   ⍝ Runs for at least 1000 sampels
      monino←0
      ⍝ Winsetup
      :Repeat
     
          nousedcandis nototfound←gauge[3 4]+acugauge[3 4]
          durtot←dursec totstart
          noremcandis←nototcandis-nousedcandis
          progress←100×1-noremcandis÷nototcandis
          totestimate←nototfound÷1-noremcandis÷nototcandis
     
          monitor[monino;]←(⊃¨durtot noremcandis nototfound totestimate)
          monino+←1
     
          :If monino>¯10+⊃⍴monitor        ⍝ Extend when getting close to limit
              monitor⍪←1000 4⍴0
          :EndIf
          ⎕DL delay    ⍝ wait a few seconds
      :Until stop∨noremcandis=0
    ∇
    
    ∇ refresh seconds;s;R      ⍝ Refresh graph and instance variable monitor periodically
      :Access Public
     
      refreshrate←seconds
      :Repeat
          ⎕DL refreshrate
          varvalue[7 8 9].Caption←0⍕¨gauge acugauge(dursec start)
          s←⎕WA             ⍝ Provoce garbagecollecting
      :Until stop∨noremcandis=0
    ∇
    
    ∇ z←showpublic;list    ⍝ show puplic variables
      :Access Public
     
      list←⎕NL-2.2
      list~←'stdcubes' 'gaugegroupsize' 'vol' 'dim' 'boxcandis'
      list~←'monitor' 'totfound' 'directory'
      z←list,[0.5]⍎¨list
    ∇
      
⍝----------------------------  plot functions -----------------------------------

    ∇ R←Winsetup;sam;R;size      ⍝ Setup a small size reusable window
      :Access Public
      size←1.5×324 432
     
      '#.pgi'⎕WC'FORM' 'Samples'(56 340)(size)('COORD' 'PIXEL')('ontop' 1)('Sizeable' 1)
      '#.pgi'⎕WS'BCOL' 0 0 128
      '#.pgi'⎕WS('COORD' 'USER')('YRANGE'(324 0))('XRANGE'(0 432))   ⍝ Assumes they all fit this page!
      '#.pgi'⎕WS'event'(22 1000)1
     
      ⎕NQ'#.pgi' 1000
      ⎕DQ'#.pgi'
     
⍝      R←'Window setup OK'
    ∇
       
    ∇ monitorgrahp;R;resampel;k;rest
      :Access Public
     
      #.ch.Set'XYPLOT,BOXED'
      #.ch.Set'HEAD' 'Polyominoes at progress=',⍕round1 progress
      #.ch.Set'ycaption' 'Number of candidates'
      #.ch.Set'xcaption' 'Time in seconds'
      #.ch.Set('Key' 'Remain,Found,Estim')
      #.ch.Set('YStyle' 'ForceZero')
      #.ch.Set'style' 'xyplot'
      #.ch.Set('mark' 8)('line' 'solid')('Colour' 'blue,red,green')
      :If monino>10000
          k←⌈monino÷10000
          resampel←k×⍳⌊monino÷k
          rest←(¯1↑resampel)+1+⍳k
          resampel,←(rest<monino)/rest
          #.ch.Plot monitor[resampel;]
      :Else
          #.ch.Plot(monino 4)↑monitor     ⍝  monitor[⍳monino;]
      :EndIf
     
      #.PG←#.ch.Close
     
     ⍝ R←⎕EX↑⎕WN'#.pgi'
     
      '#.pgi'⎕WS'Caption'('Progress meter ')
     
      R←#.PostScrp.PS #.PG'#.pgi' 1.5 #.ch.∆cmap
     
      R←⎕NQ'.' 135
    ∇
    
    ⍝------------------ Callbacks ---------------------------- 

    ∇ selectnext
      phase+←1
      ⎕←'select next 'phase
     
      runwizard
     
      next.Posn+←30 0
      nextlab.Posn+←30 0
    ∇
      
    ∇ changevoldim msg
      ⎕←'change 'voledit.Value dimedit.Value
    ∇
:endClass


