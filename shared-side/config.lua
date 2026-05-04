-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG — Rotas de Coleta v2
-----------------------------------------------------------------------------------------------------------------------------------------
RouteConfig = {

	Items = {
		{ Item = "plastic",      Label = "Plástico",          Icon = "plastic",      Min = 2,  Max = 7  },
		{ Item = "copper",       Label = "Cobre",             Icon = "copper",       Min = 2,  Max = 5  },
		{ Item = "rubber",       Label = "Borracha",          Icon = "rubber",       Min = 2,  Max = 6  },
		{ Item = "glass",        Label = "Vidro",             Icon = "glass",        Min = 2,  Max = 6  },
		{ Item = "aluminum",    Label = "Alumínio",          Icon = "aluminum",    Min = 3,  Max = 5  },
		{ Item = "metalspring",  Label = "Mola Metálica",     Icon = "metalspring",  Min = 1,  Max = 2  },
		{ Item = "scrapmetal",   Label = "Sucata Metálica",   Icon = "scrapmetal",   Min = 2,  Max = 4  },
		{ Item = "sheetmetal",   Label = "Chapa Metálica",    Icon = "sheetmetal",   Min = 1,  Max = 2  },
		{ Item = "weaponparts",  Label = "Peças de Arma",     Icon = "weaponparts",  Min = 1,  Max = 2  },
		{ Item = "lithium",      Label = "Lítio",             Icon = "lithium",      Min = 1,  Max = 3  },
		{ Item = "paper",        Label = "Papel",             Icon = "paper",        Min = 2,  Max = 6  },
		{ Item = "tinta",        Label = "Tinta",             Icon = "tinta",        Min = 2,  Max = 3  },
		{ Item = "selo",         Label = "Selo",              Icon = "selo",         Min = 1,  Max = 2  },
		{ Item = "riflebody",    Label = "Corpo de Rifle",    Icon = "riflebody",    Min = 1,  Max = 2  },
		{ Item = "smgbody",      Label = "Corpo de SMG",      Icon = "smgbody",      Min = 1,  Max = 2  },
		{ Item = "pistolbody",   Label = "Corpo de Pistola",  Icon = "pistolbody",   Min = 1,  Max = 2  },
		{ Item = "gunpowder",      Label = "Pólvora",           Icon = "gunpowder",      Min = 2,  Max = 6  },
		{ Item = "capsulasmg",   Label = "Cápsula SMG",       Icon = "capsulasmg",   Min = 2,  Max = 4  },
		{ Item = "capsulapistol",Label = "Cápsula Pistola",   Icon = "capsulapistol",Min = 2,  Max = 4  },
		{ Item = "capsularifle", Label = "Cápsula Rifle",     Icon = "capsularifle", Min = 2,  Max = 4  },
		{ Item = "sulfuric",     Label = "Ácido Sulfúrico",   Icon = "sulfuric",     Min = 2,  Max = 4  },
		{ Item = "alcohol",      Label = "Álcool",            Icon = "alcohol",      Min = 1,  Max = 3  },
		{ Item = "saline",       Label = "Soro Fisiológico",  Icon = "saline",       Min = 1,  Max = 2  },
		{ Item = "acetone",      Label = "Acetona",           Icon = "acetone",      Min = 2,  Max = 3  },
		{ Item = "explosives",      Label = "Explosivos",           Icon = "explosives",      Min = 2,  Max = 3  },
	},


	MaxSelect = 5,

	-- ── Locais de abertura do painel (ponto para interagir e abrir menu) ─
	Locations = {
		vec4(-428.83,-1728.02,19.78,209.77),
		vec4(287.6,2843.81,44.7,121.89),
	},

	-- ── Raio de interação com o ponto de abertura ────────────────────────
	InteractRadius = 2.5,

	-- ── Grupos VIP e seus bônus por item ─────────────────────────────────
	-- Vip1 = +1 em todos os itens sorteados
	-- Vip2 = +2 em todos os itens sorteados
	VipGroups = {
		{ Group = "Ouro", Bonus = 1 },
		{ Group = "Diamante", Bonus = 2 },
	},

	-- ── 2 Rotas disponíveis — ambas são percorridas (uma aleatória) ───────
	Routes = {
		-- Rota 1
		{
            vec3(-1055.61, -1373.8, 5.54),
            vec3(-822.35, -1223.39, 7.36),
            vec3(-741.11, -1127.2, 10.6),
            vec3(-705.48, -1036.03, 16.11),
            vec3(-672.98, -981.81, 22.34),
            vec3(-723.25, -854.78, 22.88),
            vec3(-827.01, -698.33, 28.05),
            vec3(-582.93, -701.28, 31.22),
            vec3(-480.36, -692.88, 33.21),
            vec3(-893.94, -1162.28, 4.92),
            vec3(-1187.64, -1235.72, 6.99),
            vec3(-1220.21, -1346.04, 4.16),
            vec3(-1224.19, -1331.02, 4.25),
            vec3(-1171.09, -1380.88, 4.97),
            vec3(-1164.38, -1429.67, 4.58),
            vec3(-1150.45, -1473.73, 4.38),
            vec3(-1108.74, -1527.77, 6.25),
            vec3(-1037.15, -1605.17, 4.97),
		},
		-- Rota 2
		{
            vec3(-295.97, -1295.85, 31.26),
            vec3(-85.14, -1302.29, 29.3),
            vec3(3.31, -1309.68, 30.16),
            vec3(311.24, -1287.87, 30.82),
            vec3(487.86, -1470.4, 29.2),
            vec3(444.78, -1583.05, 29.28),
            vec3(523.35, -1828.82, 28.48),
            vec3(750.23, -1707.56, 29.23),
            vec3(877.05, -2043.2, 31.58),
            vec3(993.1, -1999.55, 31.78),
            vec3(1380.28, -1743.59, 65.31),
            vec3(1149.88, -1655.4, 36.5),
            vec3(1411.84, -1490.4, 60.66),
            vec3(1191.8, -1240.2, 36.33),
            vec3(1242.04, -1095.4, 38.52),
            vec3(1130.22, -989.2, 45.97),
            vec3(976.32, -713.96, 57.85)
		},
	},
}