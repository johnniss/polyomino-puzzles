 :class XXXX                ⍝ dummy prefix to satisfy file editor
    
     
     
    Hi John S.  

     
    Here is a little more to the permutation subject.
    
    Beside generating permutations, one can also decompose permutations into cycles
    and also determine the sign of a permutation.   
    
    Assumed context: 
    ⎕IO←0.
    

    permcycles←{⍝ Find cycles of a permutation of the vector ⍳≢⍵

     lng←≢perm←⍵
     normalize←{(⍵⍳⌊/⍵)⌽⍵}                    ⍝ Shift cycle so smalest element first
     ∪normalize∘∪¨↓⍉↑{perm[⍵]}\lng/⊂perm      ⍝ Scan apply the permutation lng times 
                                              ⍝ and retain unique cycles
     }     
     
     
     cyclesign←{ ⍝ Sign of permutation cycles
          ⊃(1 ¯1)[⊃2|+/¯1+⍴¨⍵]
      }
        

    And from here we easyly get:

    permsign←cyclesign∘permcycles    
    

    
    
    For the lovers of recursion we could also write permcycles as:

     permcycles←{⍝ Find cycles of a permutation of the vector ⍳≢⍵

     lng←≢perm←⍵                            ⍝ Local variables
     res←⍬                                  ⍝ Initial result vector
     cycles←{                               ⍝ Recursive finding cycles
         ⍬≡⍵:⍬
         res,←⊂c←∪{perm[⍵]}\lng/⊃⍵          ⍝ Follow first element thrugh its cycle elements, append cycle to result
         ∇ ⍵~c                              ⍝ Continue with the rest
     }
     dumy←cycles perm                       ⍝ Activate the process
     {(⍵⍳⌊/⍵)⌽⍵}¨res                        ⍝ Result as sideeffect, Normalized by shift smallest element to first position
   }   
   
   
   
   I will finish this with 2 more non-recursive permutation generators, 
   that funny enough both produces the same reult.
   
   First a semi oneliner for the rich in computer ressources:
   
   permz←{all←↓⍉(⍵/⍵)⊤⍳⍵*⍵ ⋄ ↑(∧/¨(⊂⍳⍵)∊¨all)/all}   ⍝ Select ⍵-digit numbers in ⍵-radix with ⍵ different digits  
   

   
   Secondly the same normal sequence done by iterative swapping of tail elements. 

    permn←{⍝ Permutations of order ⍵, ⎕io←0         ⍝ NON recursive
     bas←⌽⍳⍵                                        ⍝ Basic vector, initialy reversed-permutated
     swaps←(⊂⍳⍵){(⍵↑⍺),⌽⍵↓⍺}¨⌽⍳⍵+1                  ⍝ Tail-swaps as the basic permutaions
     drumbeat←⊃+/(!⍵)⍴¨(!⍳⍵)↑¨1                     ⍝ The sequence of swaps
     ↑{##.bas←##.bas[⍵⊃swaps]}¨drumbeat             ⍝ Each element calculated from previus, with a trace of bas
   }


permz¨⍳4                                            ⍝ Same as permn
┌→──────────────────────┐
│ ┌⊖┐ ┌→┐ ┌→──┐ ┌→────┐ │
│ ↓0│ ↓0│ ↓0 1│ ↓0 1 2│ │
│ └─┘ └─┘ │1 0│ │0 2 1│ │
│         └───┘ │1 0 2│ │
│               │1 2 0│ │
│               │2 0 1│ │
│               │2 1 0│ │
│               └─────┘ │
└───────────────────────┘

⍴¨ permz¨⍳4
┌→────────────────────────┐
│ ┌→──┐ ┌→──┐ ┌→──┐ ┌→──┐ │
│ │1 0│ │1 1│ │2 2│ │6 3│ │
│ └───┘ └───┘ └───┘ └───┘ │
└─────────────────────────┘
