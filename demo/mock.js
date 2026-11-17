/* PikaBlu · versioni demonstrues
   Të gjitha të dhënat këtu janë fiktive. Nuk lidhet me Supabase dhe nuk ruan asgjë. */
var SUPABASE_URL = "https://demo.local", SUPABASE_KEY = "demo";
(function(){
  var U = {id: "demo-admin", email: "demo@pikablu.al", user_metadata: {username: "Administratori Demo"}};
  var now = new Date(), iso = now.toISOString(), today = iso.slice(0, 10);
  var ago = function(h){ return new Date(now.getTime() - h * 3600e3).toISOString(); };
  var day = function(d){ return new Date(now.getTime() - d * 864e5).toISOString().slice(0, 10); };
  var P = function(id, name, cats, lat, lng, extra){ return Object.assign({id: id, name: name, categories: cats, category: cats[cats.length - 1], lat: lat, lng: lng, owner: "demo-admin", owner_name: "Administratori Demo", created_at: ago(id * 5), zone_id: 1}, extra || {}); };
  var B = [
    P(1, "Pallati 7, Lagjja Kodër", ["Banesa", "Pallat"], 40.2352, 20.3489),
    P(2, "Hotel Vjosa Demo", ["Biznese", "Hotel"], 40.2331, 20.3528, {contract_no: "10234", phone: "069 000 0001", meter_no: "M-778", seal_no: "V-12", contract_status: "aktiv"}),
    P(3, "Shtëpia Demo 1", ["Banesa", "Shtëpi private"], 40.2316, 20.3494, {contract_no: "10411", debtor: true, old_debt_amount: 32000, contract_status: "prere", is_cut: true}),
    P(4, "Shkolla 9-vjeçare Demo", ["Institucion", "Shkollë"], 40.2368, 20.3546, {contract_no: "20011", contract_status: "aktiv"}),
    P(5, "Kolektori i lagjes", ["Kolektor"], 40.2381, 20.3511),
    P(6, "Bar Kafe Demo", ["Biznese", "Bar-kafe"], 40.2342, 20.3468, {contract_no: "10555", debtor: true, contract_status: "aktiv"}),
    P(7, "Qendra Shëndetësore Demo", ["Institucion", "Qendër shëndetësore"], 40.2325, 20.3561, {contract_no: "20044", contract_status: "aktiv"}),
    P(8, "Market Demo", ["Biznese", "Market"], 40.2337, 20.3502, {contract_no: "10620", contract_status: "aktiv"}),
    P(9, "Shtëpia Demo 2", ["Banesa", "Shtëpi private"], 40.2302, 20.3522, {contract_no: "10702", contract_status: "pasiv"}),
    P(10, "Pallati 3, Rruga e Urës", ["Banesa", "Pallat me kasetë të përbashkët"], 40.2329, 20.3478),
    P(11, "Restorant Demo", ["Biznese", "Restorant"], 40.2358, 20.3532, {contract_no: "10810", debtor: true, old_debt_amount: 18500, contract_status: "aktiv"}),
    P(12, "Shtëpia Demo 3 (Petran)", ["Banesa", "Shtëpi private"], 40.2208, 20.3871, {contract_no: "36100004", zone_id: 2}),
    P(13, "Kolektori Petran", ["Kolektor"], 40.2196, 20.3898, {zone_id: 2}),
    P(14, "Shtëpia Demo 4 (Bënjë)", ["Banesa", "Shtëpi private"], 40.2465, 20.4210, {contract_no: "36200002", zone_id: 3})
  ];
  var A = function(id, n, c, z, zn){ var p = n.split(" "); return {id: id, full_name: n, first_name: p[0], last_name: p[p.length - 1], contract_no: c, zone_id: z, zone_name: zn, batch: "demo.xlsx"}; };
  var abon = [
    A(1, "Agron Demo", "10234", 1, "Përmet qytet"), A(2, "Besnik Demo", "10411", 1, "Përmet qytet"), A(3, "Klajdi Demo", "10555", 1, "Përmet qytet"),
    A(4, "Elona Demo", "10620", 1, "Përmet qytet"), A(5, "Dritan Demo", "10702", 1, "Përmet qytet"), A(6, "Fatbardha Demo", "10810", 1, "Përmet qytet"),
    A(7, "Gentian Demo", "10901", 1, "Përmet qytet"), A(8, "Hysen Demo", "10902", 1, "Përmet qytet"), A(9, "Ilda Demo", "10903", 1, "Përmet qytet"),
    A(10, "Jorgo Demo", "10904", 1, "Përmet qytet"), A(11, "Lindita Demo", "10905", 1, "Përmet qytet"), A(12, "Marsela Demo", "10906", 1, "Përmet qytet"),
    A(13, "Agim Shembull", "36100001", 2, "Petran"), A(14, "Bardhyl Shembull", "36100002", 2, "Petran"), A(15, "Valbona Shembull", "36100003", 2, "Petran"),
    A(16, "Ardit Shembull", "36100004", 2, "Petran"), A(17, "Sokol Shembull", "36100005", 2, "Petran"), A(18, "Teuta Shembull", "36100006", 2, "Petran"),
    A(19, "Agron Prova", "36200001", 3, "Bënjë"), A(20, "Blerina Prova", "36200002", 3, "Bënjë"), A(21, "Kostandin Prova", "36200003", 3, "Bënjë"),
    A(22, "Mirela Prova", "36200004", 3, "Bënjë"), A(23, "Nertil Prova", "36200005", 3, "Bënjë")
  ];
  var T = {
    businesses: B,
    abonentet: abon,
    zones: [{id: 1, name: "Përmet qytet", kind: "qytet"}, {id: 2, name: "Petran", kind: "fshat"}, {id: 3, name: "Bënjë", kind: "fshat"}],
    uploaders: [{user_id: "demo-admin"}],
    staff_profiles: [{user_id: "demo-admin", full_name: "Administratori Demo", title: "Administrator i sistemit", sector: "Drejtoria, Njësia Përmet", role: "admin"}],
    subscribers: [
      {id: 1, point_id: 1, full_name: "Gentian Demo", apartment: "Hyrja 1, ap. 3", contract_no: "10901", contract_status: "aktiv"},
      {id: 2, point_id: 1, full_name: "Hysen Demo", apartment: "Hyrja 1, ap. 5", contract_no: "10902", debtor: true, old_debt_amount: 12400, contract_status: "aktiv"},
      {id: 3, point_id: 10, full_name: "Ilda Demo", apartment: "Hyrja 2, ap. 1", contract_no: "10903", contract_status: "aktiv"}
    ],
    debtors: [
      {id: 1, full_name: "Besnik Demo", contract_no: "10411", amount: 32000, invoices: 6, zone_kind: "qytet", batch: "debitoret_demo.xlsx", list_date: day(3), created_at: iso, water: 20000, sewer: 12000},
      {id: 2, full_name: "Klajdi Demo", contract_no: "10555", amount: 54500, invoices: 9, zone_kind: "qytet", batch: "debitoret_demo.xlsx", list_date: day(3), created_at: iso, water: 38000, sewer: 16500},
      {id: 3, full_name: "Fatbardha Demo", contract_no: "10810", amount: 18500, invoices: 4, zone_kind: "qytet", batch: "debitoret_demo.xlsx", list_date: day(3), created_at: iso},
      {id: 4, full_name: "Hysen Demo", contract_no: "10902", amount: 12400, invoices: 3, zone_kind: "qytet", batch: "debitoret_demo.xlsx", list_date: day(3), created_at: iso},
      {id: 5, full_name: "Bardhyl Shembull", contract_no: "36100002", amount: 9600, invoices: 2, zone_kind: "fshat", batch: "fshatrat_demo.xlsx", list_date: day(3), created_at: iso},
      {id: 6, full_name: "Kostandin Prova", contract_no: "36200003", amount: 7300, invoices: 2, zone_kind: "fshat", batch: "fshatrat_demo.xlsx", list_date: day(3), created_at: iso}
    ],
    interventions: [
      {id: 1, point_id: 6, action: "Paralajmërim", check_date: today, subscriber_name: "Bar Kafe Demo", contract_no: "10555", staff_kind: "Stafi shoqërues", staff_name: "Specialistë: Specialisti Demo", created_by: "demo-admin", created_name: "Administratori Demo", created_at: ago(3), debt_amount: 54500, payment_status: "ne_pritje"},
      {id: 2, point_id: 3, action: "Prerje", check_date: today, subscriber_name: "Besnik Demo", contract_no: "10411", staff_kind: "Stafi shoqërues", staff_name: "Hidraulikë: Hidrauliku Demo", created_by: "demo-admin", created_name: "Administratori Demo", created_at: ago(2), debt_amount: 32000, payment_status: "nuk_pagoi", payment_date: today, payment_by: "Administratori Demo"},
      {id: 3, point_id: 11, action: "Paralajmërim", check_date: today, subscriber_name: "Restorant Demo", contract_no: "10810", created_by: "demo-admin", created_name: "Administratori Demo", created_at: ago(1), debt_amount: 18500, payment_status: "pagoi", payment_date: today, payment_by: "Administratori Demo"},
      {id: 4, point_id: 2, action: "Kontroll", check_date: today, subscriber_name: "Hotel Vjosa Demo", contract_no: "10234", created_by: "demo-admin", created_name: "Administratori Demo", created_at: ago(4), note: "Matësi në gjendje të mirë."},
      {id: 5, point_id: 1, action: "Paralajmërim", check_date: day(4), subscriber_name: "Hysen Demo", subscriber_id: 2, contract_no: "10902", created_by: "demo-admin", created_name: "Administratori Demo", created_at: ago(96), debt_amount: 12400, payment_status: "ne_pritje"}
    ],
    defects: [
      {id: 1, kind: "Rrjedhje uji", status: "e_re", urgent: false, source: "qytetar", created_at: ago(1), reporter_phone: "069 000 0002", description: "Rrjedhje uji pranë kryqëzimit.", address: "Rruga Demo 1", lat: 40.2321, lng: 20.3512, media: []},
      {id: 2, kind: "Pusetë pa kapak ose e thyer", status: "ne_pune", urgent: true, source: "staf", created_name: "Zyra e klientit", created_at: ago(2), address: "Rruga e Urës", lat: 40.2333, lng: 20.3483, media: []},
      {id: 3, kind: "Tubacion i dëmtuar", status: "rregulluar", urgent: false, source: "staf", created_name: "Hidrauliku Demo", created_at: ago(5), point_name: "Kolektori i lagjes", lat: 40.2381, lng: 20.3511, description: "Tubi Ø63 u zëvendësua.", media: []},
      {id: 4, kind: "Mungesë uji", status: "e_re", urgent: false, source: "qytetar", created_at: ago(6), reporter_phone: "068 000 0003", address: "Lagjja Kodër", media: []}
    ],
    complaints: [
      {id: 1, form_no: 14, kind: "Për mbifaturim", items: ["Për mbifaturim"], status: "e_re", created_at: ago(2), created_name: "Zyra e klientit", first_name: "Elona", last_name: "Demo", complainant_name: "Elona Demo", complainant_phone: "067 000 0004", contract_no: "10620", description: "Fatura e muajit është më e lartë se zakonisht.", point_id: 8, point_name: "Market Demo"},
      {id: 2, form_no: 13, kind: "Verifikim ujëmatësi", items: ["Verifikim ujëmatësi"], status: "caktuar", staff: "Hidrauliku Demo", deadline: day(-2), created_at: ago(26), created_name: "Zyra e klientit", complainant_name: "Dritan Demo", contract_no: "10702", scan_path: "demo.pdf", scan_sent_at: ago(25)},
      {id: 3, form_no: 12, kind: "Rilidhje uji", items: ["Rilidhje uji"], status: "zgjidhur", resolution: "U rilidh pas pagesës.", created_at: ago(50), created_name: "Zyra e klientit", complainant_name: "Gentian Demo", contract_no: "10901", scan_path: "demo2.pdf", scan_sent_at: ago(49)}
    ],
    plan_folders: [{id: 1, name: "Rrjeti i ujësjellësit", parent_id: null}, {id: 2, name: "Kanalizimet", parent_id: null}],
    planimetri: [{id: 1, title: "Skema e rrjetit, qendra", path: "a.pdf", folder_id: null, created_at: ago(200)}, {id: 2, title: "Depoja e ujit", path: "b.pdf", folder_id: 1, created_at: ago(300)}]
  };
  var NET = {legend: [["Linja kryesore Ø160", "#0558FC"], ["Shpërndarëse Ø110", "#14AEFC"], ["Kanalizime Ø200", "#C98A00"]], features: [
    {geometry: {coordinates: [[20.3460, 40.2390], [20.3490, 40.2365], [20.3517, 40.2340], [20.3545, 40.2318], [20.3580, 40.2300]]}, properties: {c: "#0558FC", l: "Linja kryesore Ø160"}},
    {geometry: {coordinates: [[20.3490, 40.2365], [20.3489, 40.2352], [20.3478, 40.2329], [20.3494, 40.2316]]}, properties: {c: "#14AEFC", l: "Shpërndarëse Ø110"}},
    {geometry: {coordinates: [[20.3517, 40.2340], [20.3528, 40.2331], [20.3561, 40.2325]]}, properties: {c: "#14AEFC", l: "Shpërndarëse Ø110"}},
    {geometry: {coordinates: [[20.3517, 40.2340], [20.3532, 40.2358], [20.3546, 40.2368], [20.3511, 40.2381]]}, properties: {c: "#14AEFC", l: "Shpërndarëse Ø110"}},
    {geometry: {coordinates: [[20.3468, 40.2342], [20.3502, 40.2337], [20.3522, 40.2302]]}, properties: {c: "#C98A00", l: "Kanalizime Ø200"}}
  ]};
  function Q(t){ this.t = t; this.f = []; this.one = false; this.headCount = false; this.op = "select"; this.payload = null; this.ord = null; }
  ["range", "limit", "neq", "is", "in", "gte", "lte", "gt", "lt", "not", "or", "ilike"].forEach(function(m){ Q.prototype[m] = function(){ return this; }; });
  Q.prototype.order = function(k, o){ if (!this.ord) this.ord = [k, !(o && o.ascending === false)]; return this; };
  Q.prototype.select = function(c, o){ if (o && o.head) this.headCount = true; return this; };
  Q.prototype.eq = function(k, v){ this.f.push([k, v]); return this; };
  Q.prototype.maybeSingle = function(){ this.one = true; return this; };
  Q.prototype.single = function(){ this.one = true; return this; };
  Q.prototype.insert = function(r){ this.op = "insert"; this.payload = r; return this; };
  Q.prototype.update = function(r){ this.op = "update"; this.payload = r; return this; };
  Q.prototype.delete = function(){ this.op = "delete"; return this; };
  Q.prototype.then = function(res, rej){
    var self = this, rows = (T[this.t] || []).filter(function(r){ return self.f.every(function(f){ return String(r[f[0]]) === String(f[1]); }); });
    if (this.ord) { var k = this.ord[0], asc = this.ord[1]; rows = rows.slice().sort(function(a, b){ var x = a[k], y = b[k]; if (x == null) return 1; if (y == null) return -1; return (x > y ? 1 : x < y ? -1 : 0) * (asc ? 1 : -1); }); }
    var out;
    if (this.op === "insert") { var arr = Array.isArray(this.payload) ? this.payload : [this.payload], ins = arr.map(function(p, i){ return Object.assign({id: Date.now() + i, created_at: new Date().toISOString(), created_by: U.id}, p); }); T[this.t] = (T[this.t] || []).concat(ins); out = {data: this.one ? ins[0] : ins, error: null}; }
    else if (this.op === "update") { rows.forEach(function(r){ Object.assign(r, self.payload); }); out = {data: this.one ? rows[0] : rows, error: null}; }
    else if (this.op === "delete") { T[this.t] = (T[this.t] || []).filter(function(r){ return rows.indexOf(r) < 0; }); out = {data: rows, error: null}; }
    else if (this.headCount) out = {data: null, count: rows.length, error: null};
    else out = {data: this.one ? (rows[0] ? JSON.parse(JSON.stringify(rows[0])) : null) : JSON.parse(JSON.stringify(rows)), error: null};
    return Promise.resolve(out).then(res, rej);
  };
  var storage = {from: function(){ return {
    createSignedUrls: function(p){ return Promise.resolve({data: p.map(function(x){ return {path: x, signedUrl: null}; })}); },
    createSignedUrl: function(){ return Promise.resolve({data: {signedUrl: "about:blank"}}); },
    download: function(){ return Promise.resolve({data: {text: function(){ return Promise.resolve(JSON.stringify(NET)); }}, error: null}); },
    upload: function(){ return Promise.resolve({error: null}); },
    remove: function(){ return Promise.resolve({error: null}); }
  }; }};
  var auth = {
    getSession: function(){ return new Promise(function(r){ setTimeout(function(){ r({data: {session: {user: U}}}); }, 300); }); },
    onAuthStateChange: function(cb){ setTimeout(function(){ cb("SIGNED_IN", {user: U}); }, 350); return {data: {subscription: {unsubscribe: function(){}}}}; },
    signInWithPassword: function(){ return Promise.resolve({error: null}); },
    updateUser: function(){ return Promise.resolve({error: null}); },
    signOut: function(){ return Promise.resolve({}); }
  };
  window.supabase = {createClient: function(){ return {from: function(t){ return new Q(t); }, storage: storage, auth: auth}; }};
  window.PB_DEMO = true;
})();
