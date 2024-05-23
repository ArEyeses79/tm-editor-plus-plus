// radians
float NormalizeAngle(float angle) {
    float orig = angle;
    uint count = 0;
    while (angle < NegPI && count < 100) {
        angle += TAU;
        count++;
    }
    while (angle >= PI && count < 100) {
        angle -= TAU;
        count++;
    }
    if (count >= 100) {
        print("NormalizeAngle: count >= 100, " + orig + " -> " + angle);
    }
    return angle;
}

bool AnglesVeryClose(const quat &in q1, const quat &in q2, bool allowConjugate = false) {
    auto dot = Math::Abs(q1.x*q2.x + q1.y*q2.y + q1.z*q2.z + q1.w*q2.w);
    // technically, the angles are only the same if the quaternions are the same, but sometimes the game will give us the conjugate (e.g., circle cps seem to have this happen)
    // example: i tell it to place at PYR 0,180,90, but it places 180,0,90
    // idk, adding < 0.0001 fixes it, though.
    return dot > 0.9999 || (allowConjugate && dot < 0.0001);
}

bool AnglesVeryClose(const vec3 &in a, const vec3 &in b) {
    return AnglesVeryClose(quat(a), quat(b), true);

    // when close, q ~= quat(0,0,0,1)
    // auto q = quat(a).Inverse() * quat(b);
    // return q.xyz.LengthSquared() < 0.0001 && (q.z > 0.9999 || q.z < -0.9999);

    // print("close?" + (quat(a).Inverse() * quat(b)).ToString());
    // return (quat(a).Inverse() * quat(b)).LengthSquared() < 0.0001;
    // return Math::Abs(NormalizeAngle(a.x - b.x)) < 0.0001 &&
    //        Math::Abs(NormalizeAngle(a.y - b.y)) < 0.0001 &&
    //        Math::Abs(NormalizeAngle(a.z - b.z)) < 0.0001;
}

// shared float CardinalDirectionToYaw(int dir) {
//     // n:0, e:1, s:2, w:3
//     return -Math::PI/2. * float(dir) + (dir >= 2 ? TAU : 0);
// }

float CardinalDirectionToYaw(int dir) {
    return NormalizeAngle(-1.0 * float(dir % 4) * Math::PI/2.);
}

int YawToCardinalDirection(float yaw) {
    // NormalizeAngle(yaw) * -1.0 / Math::PI * 2.0;
    int dir = int(Math::Ceil(-NormalizeAngle(yaw) / Math::PI * 2.));
    while (dir < 0) {
        dir += 4;
    }
    return dir % 4;
}

CGameCursorBlock::EAdditionalDirEnum YawToAdditionalDir(float yaw) {
    if (yaw < 0 || yaw > HALF_PI) {
        NotifyWarning("YawToAdditionalDir: yaw out of range: " + yaw);
    }
    int yawStep = Math::Clamp(int(Math::Floor(yaw / HALF_PI * 6. + 0.0001) % 6), 0, 5);
    return CGameCursorBlock::EAdditionalDirEnum(yawStep);
}

float AdditionalDirToYaw(CGameCursorBlock::EAdditionalDirEnum aDir) {
    return float(int(aDir)) / 6. * HALF_PI;
}

vec2 Nat2ToVec2(nat2 coord) {
    return vec2(coord.x, coord.y);
}
nat2 Vec2ToNat2(vec2 v) {
    return nat2(uint(v.x), uint(v.y));
}
vec3 Nat3ToVec3(nat3 coord) {
    return vec3(coord.x, coord.y, coord.z);
}
nat3 Vec3ToNat3(vec3 v) {
    return nat3(uint(v.x), uint(v.y), uint(v.z));
}
int3 Nat3ToInt3(nat3 coord) {
    return int3(coord.x, coord.y, coord.z);
}
vec3 Int3ToVec3(int3 coord) {
    return vec3(coord.x, coord.y, coord.z);
}
nat3 Int3ToNat3(int3 coord) {
    return nat3(coord.x, coord.y, coord.z);
}
quat Vec4ToQuat(vec4 v) {
    return quat(v.x, v.y, v.z, v.w);
}
vec4 QuatToVec4(quat q) {
    return vec4(q.x, q.y, q.z, q.w);
}

const vec3 MAP_COORD = vec3(32., 8., 32.);
const vec3 HALF_COORD = vec3(16., 4., 16.);

vec3 CoordToPos(nat3 coord) {
    return vec3(coord.x * 32, (int(coord.y) - 8) * 8, coord.z * 32);
}

vec3 CoordToPos(vec3 coord) {
    return vec3(coord.x * 32, (int(coord.y) - 8) * 8, coord.z * 32);
}

vec3 MTCoordToPos(int3 mtCoord, vec3 mtBlockSize = vec3(10.66666, 8., 10.66666)) {
    return vec3((mtCoord.x + 0) * mtBlockSize.x, (mtCoord.y - 8) * mtBlockSize.y, (mtCoord.z + 0) * mtBlockSize.z);
}

vec3 MTCoordToPos(nat3 mtCoord, vec3 mtBlockSize = vec3(10.66666, 8., 10.66666)) {
    return vec3((mtCoord.x + 0) * mtBlockSize.x, (mtCoord.y - 8) * mtBlockSize.y, (mtCoord.z + 0) * mtBlockSize.z);
}

vec3 MTCoordToPos(vec3 mtCoord, vec3 mtBlockSize = vec3(10.66666, 8., 10.66666)) {
    return vec3((mtCoord.x + 0) * mtBlockSize.x, (mtCoord.y - 8) * mtBlockSize.y, (mtCoord.z + 0) * mtBlockSize.z);
}

vec3 CoordDistToPos(int3 coord) {
    return vec3(coord.x * 32, coord.y * 8, coord.z * 32);
}

vec3 CoordDistToPos(vec3 coord) {
    return vec3(coord.x * 32, (int(coord.y)) * 8, coord.z * 32);
}

nat3 PosToCoord(vec3 pos) {
    return nat3(
        uint(Math::Floor(pos.x / 32.)),
        uint(Math::Floor(pos.y / 8. + 8.)),
        uint(Math::Floor(pos.z / 32.))
    );
}

int3 PosToCoordDist(vec3 pos) {
    return int3(
        uint(Math::Floor(pos.x / 32.)),
        uint(Math::Floor(pos.y / 8.)),
        uint(Math::Floor(pos.z / 32.))
    );
}

// mat4 QuatToMat4(quat &in q) {
//     float x = q.x, y = q.y, z = q.z, w = q.w;
//     float x2 = x + x, y2 = y + y, z2 = z + z;
//     float xx = x * x2, xy = x * y2, xz = x * z2;
//     float yy = y * y2, yz = y * z2, zz = z * z2;
//     float wx = w * x2, wy = w * y2, wz = w * z2;
//     return mat4(
//         vec4(1.0 - (yy + zz), xy + wz, xz - wy, 0.0),
//         vec4(xy - wz, 1.0 - (xx + zz), yz + wx, 0.0),
//         vec4(xz + wy, yz - wx, 1.0 - (xx + yy), 0.0),
//         vec4(0.0, 0.0, 0.0, 1.0)
//     );
// }
mat4 QuatToMat4(const quat &in q) {
    float x = q.x, y = q.y, z = q.z, w = q.w;
    float x2 = x + x, y2 = y + y, z2 = z + z;
    float xx = x * x2, yy = y * y2, zz = z * z2;
    float xy = x * y2, xz = x * z2, yz = y * z2;
    float wx = w * x2, wy = w * y2, wz = w * z2;

    return mat4(
        vec4(1.0f - (yy + zz), xy - wz, xz + wy, 0.0f),
        vec4(xy + wz, 1.0f - (xx + zz), yz - wx, 0.0f),
        vec4(xz - wy, yz + wx, 1.0f - (xx + yy), 0.0f),
        vec4(0.0f, 0.0f, 0.0f, 1.0f)
    );
}

quat EulerToQuat(vec3 e) {
    throw('broken');
    // Convert Euler angles from degrees to radians
    float cy = Math::Cos(e.y * 0.5);
    float sy = Math::Sin(e.y * 0.5);
    float cz = Math::Cos(e.z * 0.5);
    float sz = Math::Sin(e.z * 0.5);
    float cx = Math::Cos(e.x * 0.5);
    float sx = Math::Sin(e.x * 0.5);

    // Quaternion conversion respecting the XZY rotation order
    return quat(
        cx * sy * sz - sx * cy * cz,
        cx * cy * cz + sx * sy * sz,
        cx * cy * sz - sx * sy * cz,
        sx * cy * sz + cx * sy * cz
    );
}

// quat Mat4ToQuat(mat4 m) {
//     vec3 e = PitchYawRollFromRotationMatrix(m);
//     return EulerToQuat(e);
// }


quat Mat4ToQuat(mat4 &in m) {
    // seems to work with QuatToMat4
    // but doesn't match the EulerToMat
    float tr = m.xx + m.yy + m.zz;
    float qw, qx, qy, qz;
    if (tr > 0) {
        float S = Math::Sqrt(tr + 1.0) * 2; // S=4*qw
        qw = 0.25 * S;
        qx = (m.zy - m.yz) / S;
        qy = (m.xz - m.zx) / S;
        qz = (m.yx - m.xy) / S;
    } else if ((m.xx > m.yy) && (m.xx > m.zz)) {
        float S = Math::Sqrt(1.0 + m.xx - m.yy - m.zz) * 2; // S=4*qx
        qw = (m.zy - m.yz) / S;
        qx = 0.25 * S;
        qy = (m.xy + m.yx) / S;
        qz = (m.xz + m.zx) / S;
    } else if (m.yy > m.zz) {
        float S = Math::Sqrt(1.0 + m.yy - m.xx - m.zz) * 2; // S=4*qy
        qw = (m.xz - m.zx) / S;
        qx = (m.xy + m.yx) / S;
        qy = 0.25 * S;
        qz = (m.yz + m.zy) / S;
    } else {
        float S = Math::Sqrt(1.0 + m.zz - m.xx - m.yy) * 2; // S=4*qz
        qw = (m.yx - m.xy) / S;
        qx = (m.xz + m.zx) / S;
        qy = (m.yz + m.zy) / S;
        qz = 0.25 * S;
    }
    return quat(qx, qy, qz, qw);
}

// from threejs Euler.js -- order XZY then *-1 at the end
vec3 PitchYawRollFromRotationMatrix(mat4 m) {
    float m11 = m.xx, m12 = m.xy, m13 = m.xz,
          m21 = m.yx, m22 = m.yy, m23 = m.yz,
          m31 = m.zx, m32 = m.zy, m33 = m.zz
    ;
    vec3 e = vec3();
    e.z = Math::Asin( - Math::Clamp( m12, -1.0, 1.0 ) );
    if ( Math::Abs( m12 ) < 0.9999999 ) {
        e.x = Math::Atan2( m32, m22 );
        e.y = Math::Atan2( m13, m11 );
    } else {
        e.x = Math::Atan2( - m23, m33 );
        e.y = 0;
    }
    return e * -1.;
}


// mat4 EulerToMat4_Inv(vec3 euler) {
//     // order XZY
//     return mat4::Inverse(EulerToMat(euler));
// }


// From Rxelux's `mat4x` lib, modified
mat4 EulerToMat(vec3 euler) {
    // mat4 translation = mat4::Translate(position*-1);
    mat4 pitch = mat4::Rotate(-euler.x,vec3(1,0,0));
    mat4 roll = mat4::Rotate(-euler.z,vec3(0,0,1));
    mat4 yaw = mat4::Rotate(-euler.y,vec3(0,1,0));
    return mat4::Inverse(pitch*roll*yaw/* *translation */);
}

float Rand01() {
    return Math::Rand(0.0, 1.0);
}

float RandM1To1() {
    return Math::Rand(-1.0, 1.0);
}

vec2 RandVec2Norm() {
    return vec2(RandM1To1(), RandM1To1()).Normalized();
}

vec3 RandVec3() {
    return vec3(RandM1To1(), RandM1To1(), RandM1To1());
}

vec3 RandVec3Norm() {
    return vec3(RandM1To1(), RandM1To1(), RandM1To1()).Normalized();
}

vec3 RandEuler() {
    return vec3(Rand01() * TAU - PI, Rand01() * TAU - PI, Rand01() * TAU - PI);
}

vec4 RandVec4Norm() {
    return vec4(RandM1To1(), RandM1To1(), RandM1To1(), RandM1To1()).Normalized();
}
