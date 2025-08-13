// Generates a base grid that fills a specified total size with gridfinity-compatible baseplates

// Parameters - set these for your drawer/space
total_width = 500;   // Total width in mm (e.g., 500mm for 50cm drawer)
total_height = 500;  // Total height in mm (e.g., 500mm for 50cm drawer)

// Gridfinity constants
GRID_UNIT_SIZE = 42;    // Standard gridfinity unit size (42mm x 42mm)
BASE_HEIGHT = 5;        // Height of baseplate
CORNER_RADIUS = 4;      // Corner radius (8mm diameter = 4mm radius)
WALL_THICKNESS = 2.5;   // Wall thickness

// Calculate grid layout
function calc_grid_layout(total_size) = 
    let(
        full_units = floor(total_size / GRID_UNIT_SIZE),
        remaining_space = total_size - (full_units * GRID_UNIT_SIZE),
        partial_unit_size = remaining_space > 0 ? remaining_space : 0
    ) [full_units, partial_unit_size];

width_layout = calc_grid_layout(total_width);
height_layout = calc_grid_layout(total_height);

full_units_x = width_layout[0];
partial_x = width_layout[1];
full_units_y = height_layout[0];
partial_y = height_layout[1];

echo(str("Grid layout: ", full_units_x, "x", full_units_y, " full units"));
echo(str("Partial units: X=", partial_x, "mm, Y=", partial_y, "mm"));

// Single gridfinity baseplate unit
module gridfinity_baseplate_unit(unit_width = GRID_UNIT_SIZE, unit_height = GRID_UNIT_SIZE) {
    difference() {
        // Outer shell with rounded corners
        hull() {
            translate([CORNER_RADIUS, CORNER_RADIUS, 0])
                cylinder(h = BASE_HEIGHT, r = CORNER_RADIUS, $fn = 16);
            translate([unit_width - CORNER_RADIUS, CORNER_RADIUS, 0])
                cylinder(h = BASE_HEIGHT, r = CORNER_RADIUS, $fn = 16);
            translate([CORNER_RADIUS, unit_height - CORNER_RADIUS, 0])
                cylinder(h = BASE_HEIGHT, r = CORNER_RADIUS, $fn = 16);
            translate([unit_width - CORNER_RADIUS, unit_height - CORNER_RADIUS, 0])
                cylinder(h = BASE_HEIGHT, r = CORNER_RADIUS, $fn = 16);
        }
        
        // Inner cutout (hollow frame)
        translate([WALL_THICKNESS, WALL_THICKNESS, WALL_THICKNESS]) {
            hull() {
                inner_corner_r = CORNER_RADIUS - WALL_THICKNESS;
                inner_width = unit_width - 2 * WALL_THICKNESS;
                inner_height = unit_height - 2 * WALL_THICKNESS;
                
                if(inner_corner_r > 0) {
                    translate([inner_corner_r, inner_corner_r, 0])
                        cylinder(h = BASE_HEIGHT, r = inner_corner_r, $fn = 16);
                    translate([inner_width - inner_corner_r, inner_corner_r, 0])
                        cylinder(h = BASE_HEIGHT, r = inner_corner_r, $fn = 16);
                    translate([inner_corner_r, inner_height - inner_corner_r, 0])
                        cylinder(h = BASE_HEIGHT, r = inner_corner_r, $fn = 16);
                    translate([inner_width - inner_corner_r, inner_height - inner_corner_r, 0])
                        cylinder(h = BASE_HEIGHT, r = inner_corner_r, $fn = 16);
                } else {
                    cube([inner_width, inner_height, BASE_HEIGHT]);
                }
            }
        }
    }
}

// Generate the complete grid
module gridfinity_base_grid() {
    // Full-size units
    for(x = [0 : full_units_x - 1]) {
        for(y = [0 : full_units_y - 1]) {
            translate([x * GRID_UNIT_SIZE, y * GRID_UNIT_SIZE, 0])
                gridfinity_baseplate_unit();
        }
    }
    
    // Partial units on the right edge
    if(partial_x > 0) {
        for(y = [0 : full_units_y - 1]) {
            translate([full_units_x * GRID_UNIT_SIZE, y * GRID_UNIT_SIZE, 0])
                gridfinity_baseplate_unit(partial_x, GRID_UNIT_SIZE);
        }
    }
    
    // Partial units on the top edge
    if(partial_y > 0) {
        for(x = [0 : full_units_x - 1]) {
            translate([x * GRID_UNIT_SIZE, full_units_y * GRID_UNIT_SIZE, 0])
                gridfinity_baseplate_unit(GRID_UNIT_SIZE, partial_y);
        }
    }
    
    // Corner partial unit (if both partial dimensions exist)
    if(partial_x > 0 && partial_y > 0) {
        translate([full_units_x * GRID_UNIT_SIZE, full_units_y * GRID_UNIT_SIZE, 0])
            gridfinity_baseplate_unit(partial_x, partial_y);
    }
}

// Generate the grid
gridfinity_base_grid();