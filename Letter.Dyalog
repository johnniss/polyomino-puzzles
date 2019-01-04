 :class XXXX
    
     Hej John S.
     
     I have been thinking of sending you these permutation functions for a long time.
     
     Now is the time. 
     
     They deviate from the ones already published on the Dfns site, in mainly in the shape of the result. 
     
     First one may notice that somehow there is a more natural box to contain the permutations of order N
     than just a list or rank 2 matrix of shape (!N),N
     
     And that is an array of shape 1+⍳N (⎕IO=0). 
     
     I have 2 functions doing just that, a recursive and a non-recursive.
     
     
     The third one contains the permutations as a hieracy, keeping repetitions to a minimum.  
     
     Here are the functions, execution samples and resulting shapes.  


     I hope you find it interesting enough to extend the Dfns entry about permutations.
     If you think it should be enhanced in som way, please let me know.

    

     Assuming context: ⎕IO←0


     perm1←{⍵=0:⍬ ⋄ ((⍳⍵)⌽⍵ ⍵⍴⍳⍵)[;0,1+∇ ⍵-1]}                  ⍝ Recursive indexing (modernized in 2000)
     
     permn←{i←⍳⍵  ⋄ p←(i∘~¨i),¨i ⋄ {⊃{⍵[⍺⊃p]}/⍵,⊂i}¨⍳1+i}       ⍝ Non-recursive from natural adressbox (2000)
     
     permh←{0≡⍵:⍬ ⋄ pe←{1=≢⍵:⍵ ⋄ ↑⍵∘{⍵(pe ⍺~⍵)}¨⍵} ⋄ pe ⍳⍵}     ⍝ As hiearaky (2002)

     
     
     
     
     
    

     perm1¨ ⍳4                                                  ⍝ Recursive indexing
┌→───────────────────────┐
│   ┌→┐ ┌┌→──┐ ┌┌┌→────┐ │
│ ⍬ ↓0│ ↓↓0 1│ ↓↓↓0 1 2│ │
│   └─┘ ││   │ │││     │ │
│       ││1 0│ │││0 2 1│ │
│       └└───┘ │││     │ │
│              │││     │ │
│              │││1 2 0│ │
│              │││     │ │
│              │││1 0 2│ │
│              │││     │ │
│              │││     │ │
│              │││2 0 1│ │
│              │││     │ │
│              │││2 1 0│ │
│              └└└─────┘ │
└────────────────────────┘ 

 ⍴¨ perm1¨ ⍳4
┌→────────────────────────────┐
│ ┌→┐ ┌→──┐ ┌→────┐ ┌→──────┐ │
│ │0│ │1 1│ │2 1 2│ │3 2 1 3│ │
│ └─┘ └───┘ └─────┘ └───────┘ │
└─────────────────────────────┘

     
     
     permn¨ ⍳4                                                       ⍝ Non-recursive 
┌→───────────────────────────────────────────────────────────┐
│ ┌───┐ ┌→────┐ ┌→────────────┐ ┌┌→────────────────────────┐ │
│ │   │ │ ┌→┐ │ ↓ ┌→──┐ ┌→──┐ │ ↓↓ ┌→────┐ ┌→────┐ ┌→────┐ │ │
│ │ ⍬ │ │ │0│ │ │ │0 1│ │1 0│ │ ││ │0 1 2│ │1 0 2│ │2 0 1│ │ │
│ └───┘ │ └─┘ │ │ └───┘ └───┘ │ ││ └─────┘ └─────┘ └─────┘ │ │
│       └─────┘ └─────────────┘ ││ ┌→────┐ ┌→────┐ ┌→────┐ │ │
│                               ││ │0 2 1│ │1 2 0│ │2 1 0│ │ │
│                               ││ └─────┘ └─────┘ └─────┘ │ │
│                               └└─────────────────────────┘ │
└────────────────────────────────────────────────────────────┘     
    
      ⍴¨ permn¨ ⍳4
┌→────────────────────┐
│   ┌→┐ ┌→──┐ ┌→────┐ │
│ ⍬ │1│ │1 2│ │1 2 3│ │
│   └─┘ └───┘ └─────┘ │
└─────────────────────┘     



     permh¨ ⍳4                                                          ⍝ As hiearaky
┌→────────────────────────────────┐
│   ┌→┐ ┌→──────┐ ┌→────────────┐ │
│ ⍬ │0│ ↓   ┌→┐ │ ↓   ┌→──────┐ │ │
│   └─┘ │ 0 │1│ │ │ 0 ↓   ┌→┐ │ │ │
│       │   └─┘ │ │   │ 1 │2│ │ │ │
│       │   ┌→┐ │ │   │   └─┘ │ │ │
│       │ 1 │0│ │ │   │   ┌→┐ │ │ │
│       │   └─┘ │ │   │ 2 │1│ │ │ │
│       └───────┘ │   │   └─┘ │ │ │
│                 │   └───────┘ │ │
│                 │   ┌→──────┐ │ │
│                 │ 1 ↓   ┌→┐ │ │ │
│                 │   │ 0 │2│ │ │ │
│                 │   │   └─┘ │ │ │
│                 │   │   ┌→┐ │ │ │
│                 │   │ 2 │0│ │ │ │
│                 │   │   └─┘ │ │ │
│                 │   └───────┘ │ │
│                 │   ┌→──────┐ │ │
│                 │ 2 ↓   ┌→┐ │ │ │
│                 │   │ 0 │1│ │ │ │
│                 │   │   └─┘ │ │ │
│                 │   │   ┌→┐ │ │ │
│                 │   │ 1 │0│ │ │ │
│                 │   │   └─┘ │ │ │
│                 │   └───────┘ │ │
│                 └─────────────┘ │
└─────────────────────────────────┘     
  
   ⍴¨ permh¨ ⍳4
┌→────────────────────┐
│ ┌→┐ ┌→┐ ┌→──┐ ┌→──┐ │
│ │0│ │1│ │2 2│ │3 2│ │
│ └─┘ └─┘ └───┘ └───┘ │
└─────────────────────┘     


