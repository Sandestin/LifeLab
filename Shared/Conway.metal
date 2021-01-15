//
//  Conway.metal
//  LifeLab
//
//  Created by Jonathan Attfield on 08/01/2021.
//

#include <metal_stdlib>
using namespace metal;

kernel void generation(texture2d<uint, access::read> current [[texture(0)]],
                       texture2d<uint, access::write> next [[texture(1)]],
                       uint2 index [[thread_position_in_grid]]) {
    short liveNeighbours = 0;
    
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            if (i != 0 || j != 0) {
                uint2 neighbour = index + uint2(i, j);
                if (1 == current.read(neighbour).r) {
                    liveNeighbours++;
                }
            }
        }
    }
    
    bool isAlive = 1 == current.read(index).r;
    
    if (isAlive) {
        if (liveNeighbours < 2) {
            next.write(0, index);   // Death from under population.
        } else if (liveNeighbours > 3) {
            next.write(0, index);   // Death by over population.
        } else {
            next.write(1, index);   // Life.
        }
    } else {
        if (liveNeighbours == 3) {
            next.write(1, index);   // Birth
        } else {
            next.write(0, index);   // Remain Dead
        }
    }
}

