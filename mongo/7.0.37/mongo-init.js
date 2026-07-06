/**
 * 通用 MongoDB 应用用户初始化（docker-entrypoint-initdb.d）
 * 仅在数据目录为空时执行一次；适合打入私有镜像。
 *
 * ── 单用户模式（常用）──
 * MONGO_INITDB_DATABASE   目标库名（与官方镜像一致；未设时默认 test）
 * MONGO_APP_DATABASE      应用用户所属库；默认等于 MONGO_INITDB_DATABASE
 * MONGO_APP_USER          应用用户名；未设则跳过建用户
 * MONGO_APP_PASSWORD      应用用户密码；设了 MONGO_APP_USER 时必填
 * MONGO_APP_ROLES         角色，任选其一格式：
 *                           - readWrite（默认，逗号分隔多角色：readWrite,read）
 *                           - JSON 数组：[{"role":"readWrite","db":"mydb"}]
 *
 * ── 多用户模式（可选，设置后忽略单用户变量）──
 * MONGO_INIT_USERS        JSON 数组，例如：
 *   [{"user":"u1","pwd":"p1","roles":[{"role":"readWrite","db":"db1"}]}]
 *
 * ── 其它 ──
 * MONGO_INIT_SKIP         设为 1/true/yes 时跳过本脚本
 */

function env(name, defaultValue) {
  const v = process.env[name];
  if (v === undefined || v === null || String(v).trim() === '') {
    return defaultValue;
  }
  return String(v).trim();
}

function fail(message) {
  print('ERROR: [mongo-init] ' + message);
  quit(1);
}

function isTruthy(value) {
  if (value === undefined || value === null) {
    return false;
  }
  const normalized = String(value).trim().toLowerCase();
  return normalized === '1' || normalized === 'true' || normalized === 'yes' || normalized === 'on';
}

function parseRoles(roleSpec, dbName) {
  const spec = roleSpec === undefined || roleSpec === null ? '' : String(roleSpec).trim();
  if (spec === '') {
    return [{ role: 'readWrite', db: dbName }];
  }
  if (spec.startsWith('[')) {
    let parsed;
    try {
      parsed = JSON.parse(spec);
    } catch (e) {
      fail('MONGO_APP_ROLES must be valid JSON array: ' + e.message);
    }
    if (!Array.isArray(parsed) || parsed.length === 0) {
      fail('MONGO_APP_ROLES JSON array must not be empty');
    }
    parsed.forEach(function (role, index) {
      if (!role || !role.role) {
        fail('MONGO_APP_ROLES[' + index + '] requires role');
      }
      if (!role.db) {
        role.db = dbName;
      }
    });
    return parsed;
  }
  return spec.split(',').map(function (part) {
    return { role: part.trim(), db: dbName };
  }).filter(function (role) {
    return role.role.length > 0;
  });
}

function createUserOnDb(dbName, user, password, roles) {
  if (!dbName) {
    fail('database name is required');
  }
  if (!user) {
    return;
  }
  if (!password) {
    fail('password is required for user ' + user);
  }
  if (!roles || roles.length === 0) {
    fail('at least one role is required for user ' + user);
  }
  const target = db.getSiblingDB(dbName);
  const roleSummary = roles.map(function (r) {
    return r.role + '@' + r.db;
  }).join(',');
  try {
    target.createUser({ user: user, pwd: password, roles: roles });
    print('[mongo-init] created user ' + user + ' on db=' + dbName + ' roles=' + roleSummary);
  } catch (e) {
    const msg = e && e.message ? e.message : String(e);
    if (e.codeName === 'DuplicateKey' || msg.indexOf('already exists') >= 0) {
      print('[mongo-init] user already exists, skip: ' + user + '@' + dbName);
      return;
    }
    fail('createUser failed for ' + user + '@' + dbName + ': ' + msg);
  }
}

if (isTruthy(env('MONGO_INIT_SKIP', ''))) {
  print('[mongo-init] MONGO_INIT_SKIP set, skip');
  quit(0);
}

const multiUsersJson = env('MONGO_INIT_USERS', '');
if (multiUsersJson) {
  let users;
  try {
    users = JSON.parse(multiUsersJson);
  } catch (e) {
    fail('MONGO_INIT_USERS must be valid JSON array: ' + e.message);
  }
  if (!Array.isArray(users) || users.length === 0) {
    fail('MONGO_INIT_USERS must be a non-empty JSON array');
  }
  users.forEach(function (entry, index) {
    if (!entry || !entry.user) {
      fail('MONGO_INIT_USERS[' + index + '] requires user');
    }
    if (!entry.pwd && !entry.password) {
      fail('MONGO_INIT_USERS[' + index + '] requires pwd or password');
    }
    const pwd = entry.pwd || entry.password;
    let roles = entry.roles;
    if (!Array.isArray(roles) || roles.length === 0) {
      const dbName = env('MONGO_APP_DATABASE', env('MONGO_INITDB_DATABASE', 'test'));
      roles = parseRoles(entry.role || 'readWrite', dbName);
    }
    const primaryDb = roles[0].db;
    createUserOnDb(primaryDb, entry.user, pwd, roles);
  });
  print('[mongo-init] done, users=' + users.length);
  quit(0);
}

const initDb = env('MONGO_INITDB_DATABASE', 'test');
const appDb = env('MONGO_APP_DATABASE', initDb);
const appUser = env('MONGO_APP_USER', '');
const appPassword = env('MONGO_APP_PASSWORD', '');

if (!appUser) {
  print('[mongo-init] MONGO_APP_USER not set, skip user creation (db=' + initDb + ')');
  quit(0);
}

const roles = parseRoles(env('MONGO_APP_ROLES', 'readWrite'), appDb);
createUserOnDb(appDb, appUser, appPassword, roles);
print('[mongo-init] done db=' + appDb + ' user=' + appUser);
