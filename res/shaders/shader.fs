#version 330

// Input vertex attributes (from vertex shader)
in vec3 fragPosition;
in vec2 fragTexCoord;
in vec3 fragNormal; //used for when normal mapping is toggled off
in vec4 fragColor;

// Input uniform values
uniform sampler2D diffuseTexture;
uniform sampler2D normalMapTexture;
uniform sampler2D roughnessTexture;
uniform vec3 viewPos; // Camera Position
uniform vec3 lightPos; // Light Position (might change)

uniform vec4 colDiffuse;
uniform vec4 tintColor;

// Output fragment color
out vec4 finalColor;

in mat3 TBN;

void main()
{
    // Constant Settings
    bool useNormalMap = true;
    float specularExponent = 8.0f;
    vec3 lightColor = vec3(0.5, 0.5, 0.5); // Change values to 1 for a brighter light

    vec4 texelColor = texture(diffuseTexture, vec2(fragTexCoord.x, fragTexCoord.y));
    vec3 specular = vec3(0.0);
    vec3 viewDir = normalize(viewPos - fragPosition);
    vec3 lightDir = normalize(lightPos - fragPosition);

    vec3 normal;
    if (useNormalMap) {
        normal = texture(normalMapTexture, vec2(fragTexCoord.x, fragTexCoord.y)).rgb;

        //Transform normal values to the range -1.0 ... 1.0
        normal = normalize(normal*2.0 - 1.0);

        //Transform the normal from tangent-space to world-space for lighting calculation
        normal = normalize(normal*TBN);
    } else {
        normal = normalize(fragNormal);
    }

    vec4 tint = colDiffuse * fragColor;

    float NdotL = max(dot(normal, lightDir), 0.0);
    vec3 lightDot = lightColor*NdotL;

    float specCo = 0.0;

    if (NdotL > 0.0) specCo = pow(max(0.0, dot(viewDir, reflect(-lightDir, normal))), specularExponent);

    specular += specCo;

    finalColor = (texelColor*((tint + vec4(specular, 1.0))*vec4(lightDot, 1.0)));
    finalColor += texelColor*(vec4(1.0, 1.0, 1.0, 1.0)/40.0)*tint;

    // Gamma correction
    finalColor = pow(finalColor, vec4(1.0/2.2));
    //finalColor = vec4(normal, 1.0);
}
