package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################

# acceptable score for automated authorization
blast_radius = 150

# weights assigned for each operation on each resource-type
weights = {
    "azurerm_resource_group": {"delete": 100, "create": 10, "modify": 1},
    "azurerm_container_registry": {"delete": 10, "create": 10, "modify": 1},
    "azurerm_container_group": {"delete": 10, "create": 10, "modify": 1},
    "azurerm_role_assignment": {"delete": 10, "create": 5, "modify": 1},
    "azurerm_user_assigned_identity": {"delete": 10, "create": 1, "modify": 1},
    "null_resource": {"delete": 10, "create": 10, "modify": 1}
}

# Consider exactly these resource types in calculations
resource_types = {
    "azurerm_resource_group",
    "azurerm_container_registry",
    "azurerm_container_group",
    "azurerm_role_assignment",
    "azurerm_user_assigned_identity",
    "null_resource"
}

#########
# Policy
#########

# Authorization holds if score for the plan is acceptable and no changes are made to IAM
default authz = false
authz if {
    score < blast_radius
}

# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
score = s if {
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
resources[resource_type] = all if {
    some resource_type
    resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
    ]
}

# number of deletions of resources of a given type
num_deletes[resource_type] = num if {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    deletions := [res | res := all[_]; res.change.actions[_] == "delete"]
    num := count(deletions)
}

# number of creations of resources of a given type
num_creates[resource_type] = num if {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    creates := [res | res := all[_]; res.change.actions[_] == "create"]
    num := count(creates)
}

# number of modifications to resources of a given type
num_modifies[resource_type] = num if {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    modifies := [res | res := all[_]; res.change.actions[_] == "update"]
    num := count(modifies)
}