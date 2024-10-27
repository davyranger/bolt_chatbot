package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################

# acceptable score for automated authorization
blast_radius = 30

# weights assigned for each operation on each resource-type
weights = {
    "azurerm_resource_group": {"delete": 100, "create": 10, "modify": 1},
    "azurerm_container_registry": {"delete": 10, "create": 1, "modify": 1}
}

# Consider exactly these resource types in calculations
resource_types = {
    "azurerm_resource_group", "azurerm_container_registry"
}

#########
# Policy
#########

# Authorization holds if score for the plan is acceptable and no changes are made to IAM
default authz = false
authz {
    score < blast_radius
    not touches_iam
}

# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
score = s {
    all := [ x |
            some resource_type
            crud := weights[resource_type]
            del := crud["delete"] * num_deletes[resource_type]
            new := crud["create"] * num_creates[resource_type]
            mod := crud["modify"] * num_modifies[resource_type]
            x := del + new + mod
    ]
    s := sum(all)
}

####################
# Terraform Library
####################

# list of all resources of a given type
resources[resource_type] = all {
    some resource_type
    resource_types[resource_type]
    all := [name |
        tfplan[name] = _
        startswith(name, resource_type)
    ]
}

# number of deletions of resources of a given type
num_deletes[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    deletions := [name | name := all[_]; tfplan[name]["destroy"] == true]
    num := count(deletions)
}

# number of creations of resources of a given type
num_creates[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    creates := [name | all[_] = name; tfplan[name]["id"] == ""]
    num := count(creates)
}

# number of modifications to resources of a given type
num_modifies[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    modifies := [name | name := all[_]; obj := tfplan[name]; obj["destroy"] == false; not obj["id"]]
    num := count(modifies)
}
