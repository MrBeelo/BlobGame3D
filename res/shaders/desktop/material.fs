#version 330

// Input vertex attributes (from vertex shader)
in vec3 fragPosition;
in vec2 fragTexCoord;
in vec3 fragNormal; //used for when normal mapping is toggled off
in vec4 fragColor;
in mat3 TBN;

// Input uniform values
uniform sampler2D texture0;
uniform sampler2D normalMapTexture;
uniform sampler2D roughnessTexture;

uniform vec3 viewPos; // Camera Position
uniform vec3 lightPos; // Light Position (might change)

uniform bool useNormalMap;
uniform bool useRoughness;
uniform vec3 lightColor;

uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

void main()
{
    // Textures
    float roughness = (useRoughness) ? texture(roughnessTexture, fragTexCoord).r : 0;
    
    // Directions
    vec3 viewDir = normalize(viewPos - fragPosition);
    vec3 lightDir = normalize(lightPos - fragPosition);
    float distance = length(lightPos - fragPosition);

    // Normal Map
    vec3 normal;
    if (useNormalMap) {
        normal = texture(normalMapTexture, vec2(fragTexCoord.x, fragTexCoord.y)).rgb;
        normal = normalize(normal*2.0 - 1.0);
        normal = normalize(normal*TBN);
    } else {
        normal = normalize(fragNormal);
    }

    // Lighting
    vec4 tint = colDiffuse * fragColor;
    float NdotL = max(dot(normal, lightDir), 0.0);
    float attenuation = 1.0 / (0.15 * distance * distance);
    attenuation = clamp(attenuation, 0.0, 10.0);
    vec3 lightDot = lightColor * NdotL * attenuation;
    
    // Roughness
    vec3 reflectDir = reflect(-lightDir, normal);
    float specPower = mix(8.0, 64.0, roughness); // Changed from "1 - roughness"
    float specStrength = roughness; // Changed from "1 - roughness"
    float specCo = 0.0;
    if (NdotL > 0.0) specCo = pow(max(0.0, dot(viewDir, reflectDir)), specPower);
    vec3 specular = vec3(specCo * specStrength * attenuation);

    // Final Color
    vec4 texelColor = texture(texture0, fragTexCoord);
    finalColor = (texelColor*((tint + vec4(specular, 1.0)) * vec4(lightDot, 1.0)));
    finalColor += texelColor*(vec4(1.0, 1.0, 1.0, 1.0)/40.0) * tint;
    finalColor = pow(finalColor, vec4(1.0/2.2)); // Gamma correction
}
