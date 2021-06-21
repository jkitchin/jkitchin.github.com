(setq lookout-bbdb-mapping-table
      '(("lastname" "mname" "lname")
        ("firstname" "fname")
        ("company" "company")
        ("net" "email")
        ("phones" nil)
        ("addr1" nil)
        ("addr2" nil)
        ("addr3" nil)
        ("otherfields" 
         "group" nil)
        ("notes" nil)))

(lookout-create-bbdb 

