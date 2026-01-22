"""

    connectance_index(l::Landscape, class::Int)

Calculates the Connectance Index (CONNECT) for a given class in the landscape.
Its defined as the number of functional connections between all patches of the corresponding class divided by the 
total possible number of connections between all patches of that class, multiplied by 100 to express it as a percentage.

"""


function connectance_index(l::Landscape, class::Int)

    # We get the patches
    p = patches(l)

    # We find the coordinates of the given class
    class_coordinates = findall(x -> l[x] == class, CartesianIndices(l))
    # Check that the class exists  
    if isempty(class_coordinates)
        error("class value $class not found in landscape")
    end
    # Get unique patch ids for the class
    patch_ids = unique(p[class_coordinates])
    num_patches = length(patch_ids)
    # If there is only one patch, connectance is 100%
    if num_patches <= 1
        return 100.0
    end

    # Calculate number of functional connections
    functional_connections = 0
   
    # Distance to consider patches as functionally connected
    connection_distance = 1 
    
    # If the patches are close enough, we consider them functionally connected, which means we add 1 to the sum of cijk.
    for i in 1:num_patches-1
        patch_i_coordinates = findall(isequal(patch_ids[i]), p)
        for j in i+1:num_patches
            patch_j_coordinates = findall(isequal(patch_ids[j]), p)
            # Check if any cell in patch i is within connection_distance of any cell in patch j
            connected = false
            for coord_i in patch_i_coordinates
                for coord_j in patch_j_coordinates
                    if norm(Tuple(coord_i) .- Tuple(coord_j)) <= connection_distance
                        connected = true
                        break
                    end
                end
                if connected
                    break
                end
            end
            if connected
                functional_connections += 1
            end
        end
    end

    # Total possible connections between all patches of the class based on the distance threshold
    total_possible_connections = ((num_patches * (num_patches - 1)) / 2)
    # Calculate CONNECT
    connect = (functional_connections / total_possible_connections) * 100
    return connect
end

function connectance_index(l::Landscape)
    # We get the patches
    p = patches(l)

    # Get unique class ids
    class_ids = unique(l)

    # Sum of functional connections and total possible connections for all classes
    total_functional_connections = 0
    total_possible_connections = 0

    for class_id in class_ids
        class_coordinates = findall(x -> l[x] == class_id, CartesianIndices(l))
        # Get unique patch ids for the class
        patch_ids = unique(p[class_coordinates])
        num_patches = length(patch_ids)
        # If there is only one patch, connectance is 100%
        if num_patches <= 1
            total_functional_connections += 1
            total_possible_connections += 1
            continue
        end
        # Calculate number of functional connections
        functional_connections = 0
        # Distance to consider patches as functionally connected
        connection_distance = 1
        for i in 1:num_patches-1
            patch_i_coordinates = findall(isequal(patch_ids[i]), p)
            for j in i+1:num_patches
                patch_j_coordinates = findall(isequal(patch_ids[j]), p)
                # Check if any cell in patch i is within connection_distance of any cell in patch j
                connected = false
                for coord_i in patch_i_coordinates
                    for coord_j in patch_j_coordinates
                        if norm(Tuple(coord_i) .- Tuple(coord_j)) <= connection_distance
                            connected = true
                            break
                        end
                    end
                    if connected
                        break
                    end
                end
                if connected
                    functional_connections += 1
                end
            end
        end
        # Total possible connections between all patches of the class based on the distance threshold
        possible_connections = ((num_patches * (num_patches - 1)) / 2)
        total_functional_connections += functional_connections
        total_possible_connections += possible_connections
    end
    # Calculate overall CONNECT
    connect = (total_functional_connections / total_possible_connections) * 100
    return connect
end