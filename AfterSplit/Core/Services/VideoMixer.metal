/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Shader that renders two input textures with different split styles.
*/

#include <metal_stdlib>
using namespace metal;

enum SplitStyleType: uint {
    straight = 0,
    diagonal = 1,
    circular = 2,
    corner = 3
};

struct MixerParameters {
    float2 pipPosition;
    float2 pipSize;
    uint splitStyle;
    float2 textureSize;
};

constant sampler kBilinearSampler(filter::linear, coord::pixel, address::clamp_to_edge);

// Helper function to check if point is in circle
bool isInCircle(float2 point, float2 center, float radius) {
    float dist = distance(point, center);
    return dist <= radius;
}

// Helper function to check if point is in diagonal region (top-left triangle)
bool isInDiagonalRegion(float2 point, float2 size) {
    return point.y < (point.x * size.y / size.x);
}

// Helper function to check if point is in corner region (top-right corner)
bool isInCornerRegion(float2 point, float2 size, float cornerSize) {
    return point.x > (size.x - cornerSize) && point.y < cornerSize;
}

// Compute kernel for video mixing
kernel void videoMixer(texture2d<half, access::read>     frontInput      [[ texture(0) ]],
                      texture2d<half, access::read>      backInput       [[ texture(1) ]],
                      texture2d<half, access::write>     outputTexture   [[ texture(2) ]],
                      const device    MixerParameters&    mixerParameters [[ buffer(0) ]],
                      uint2 gid [[thread_position_in_grid]])
{
    if (gid.x >= outputTexture.get_width() || gid.y >= outputTexture.get_height()) {
        return;
    }
    
    float2 position = float2(gid);
    float2 textureSize = mixerParameters.textureSize;
    SplitStyleType splitStyle = SplitStyleType(mixerParameters.splitStyle);
    
    half4 output;
    
    switch (splitStyle) {
        case straight: {
            // Side-by-side split: left half is front, right half is back
            if (position.x < textureSize.x / 2.0) {
                // Left half - front camera (scale to fit)
                uint2 frontCoord = uint2((position.x * 2.0 * frontInput.get_width()) / textureSize.x, 
                                         (position.y * frontInput.get_height()) / textureSize.y);
                if (frontCoord.x < frontInput.get_width() && frontCoord.y < frontInput.get_height()) {
                    output = frontInput.read(frontCoord);
                } else {
                    output = half4(0.0);
                }
            } else {
                // Right half - back camera (scale to fit)
                float2 backCoord = float2((position.x - textureSize.x / 2.0) * 2.0 * backInput.get_width() / textureSize.x, 
                                          position.y * backInput.get_height() / textureSize.y);
                uint2 backCoordInt = uint2(backCoord);
                if (backCoordInt.x < backInput.get_width() && backCoordInt.y < backInput.get_height()) {
                    output = backInput.read(backCoordInt);
                } else {
                    output = half4(0.0);
                }
            }
            break;
        }
        
        case diagonal: {
            // Diagonal split: top-left triangle is front, bottom-right is back
            if (isInDiagonalRegion(position, textureSize)) {
                // Top-left triangle - front camera
                // Map diagonal region to full front texture
                float2 frontCoord = position;
                if (frontCoord.x < frontInput.get_width() && frontCoord.y < frontInput.get_height()) {
                    output = frontInput.read(uint2(frontCoord));
                } else {
                    output = half4(0.0);
                }
            } else {
                // Bottom-right triangle - back camera
                float2 backCoord = position;
                if (backCoord.x < backInput.get_width() && backCoord.y < backInput.get_height()) {
                    output = backInput.read(uint2(backCoord));
                } else {
                    output = half4(0.0);
                }
            }
            break;
        }
        
        case circular: {
            // Circular PiP: back camera full screen, front camera in circular PiP
            uint2 pipPosition = uint2(mixerParameters.pipPosition);
            uint2 pipSize = uint2(mixerParameters.pipSize);
            float2 pipCenter = float2(pipPosition) + float2(pipSize) / 2.0;
            float pipRadius = min(pipSize.x, pipSize.y) / 2.0;
            
            if (isInCircle(position, pipCenter, pipRadius)) {
                // Inside circle - front camera
                float2 pipRelativePos = position - float2(pipPosition);
                float2 frontCoord = pipRelativePos * float2(frontInput.get_width(), frontInput.get_height()) / float2(pipSize);
                if (frontCoord.x < frontInput.get_width() && frontCoord.y < frontInput.get_height()) {
                    output = frontInput.read(uint2(frontCoord));
                } else {
                    output = half4(0.0);
                }
            } else {
                // Outside circle - back camera
                if (position.x < backInput.get_width() && position.y < backInput.get_height()) {
                    output = backInput.read(uint2(position));
                } else {
                    output = half4(0.0);
                }
            }
            break;
        }
        
        case corner: {
            // Corner overlay: back camera full screen, front camera in top-right corner
            uint2 pipPosition = uint2(mixerParameters.pipPosition);
            uint2 pipSize = uint2(mixerParameters.pipSize);
            
            if (position.x >= pipPosition.x && position.y >= pipPosition.y &&
                position.x < (pipPosition.x + pipSize.x) && position.y < (pipPosition.y + pipSize.y)) {
                // Inside corner region - front camera
                float2 pipRelativePos = position - float2(pipPosition);
                float2 frontCoord = pipRelativePos * float2(frontInput.get_width(), frontInput.get_height()) / float2(pipSize);
                if (frontCoord.x < frontInput.get_width() && frontCoord.y < frontInput.get_height()) {
                    output = frontInput.read(uint2(frontCoord));
                } else {
                    output = half4(0.0);
                }
            } else {
                // Outside corner region - back camera
                if (position.x < backInput.get_width() && position.y < backInput.get_height()) {
                    output = backInput.read(uint2(position));
                } else {
                    output = half4(0.0);
                }
            }
            break;
        }
        
        default:
            // Default to back camera
            if (position.x < backInput.get_width() && position.y < backInput.get_height()) {
                output = backInput.read(uint2(position));
            } else {
                output = half4(0.0);
            }
            break;
    }
    
    outputTexture.write(output, gid);
}

