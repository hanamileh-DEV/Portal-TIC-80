-- title:  Portal 3D
-- author: HanamileH, soxfox42
-- desc:   version 1.0 (powered by UniTIC v 1.3)
-- script: lua
-- saveid: portal3d_unitic

local version="DEV 0.2.1"

--[[
license:

Copyright 2022 HanamileH
Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the
Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall
be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local F, R, min, max, abs = math.floor, math.random, math.min, math.max, math.abs
local pi2 = math.pi / 2

local st={ --settings
m_s   =60, --mouse sensitivity
r_p   =true, --rendering portals
r_both=true, -- render both portals
h_q_p =false, --high quality portals
p     =true, --particles
d_t   =true, --dynamic textures
music =true,
sfx   =true,
}

save={ --saving the game
i=pmem(0)~=0, --How for the first time the player went into the game
lvl=pmem(0),
lvl2=0, --ID set of levels
st=pmem(1), --settings (All settings except the sensitivity of the mouse in binary form)
bt=pmem(2), --the best time to pass skilltests
d=pmem(3), --the number of player deaths (in the main game)
ct=pmem(4), --current time passing the main game
}

if save.st&2^31~=0 then
	st.r_p   =save.st&2^0 ~=0
	st.h_q_p =save.st&2^1 ~=0
	st.music =save.st&2^2 ~=0
	st.sfx   =save.st&2^3 ~=0
	st.r_both=save.st&2^4 ~=0
	st.p     =save.st&2^5 ~=0
	st.d_t   =save.st&2^6 ~=0
end

--camera
local cam = { x = 0, y = 0, z = 0, tx = 0, ty = 0 }
--player
local plr = { x = 95, y = 65, z = 500, tx = 0, ty = 0, vy=0 , xy=false, d = false, godmode = false, noclip = false , hp = 100 , hp2 = 100, cd = 0 , cd2 = 0, dt= 1, cd3 = 0, holding = false}
--engine settings:
local unitic = {
	version = 1.3, --engine version
	--drawing
	fov = 80, --lens distance to camera
	--system tables (dont touch)
	poly = {},
	obj  = {}, --objects
	p    = {} --particles
}
local model={
	{--cube (1)
	v={{ 24, 24, 24},{ 24,-24, 24},{ 24, 24,-24},{ 24,-24,-24},{-24, 24, 24},{-24,-24, 24},{-24, 24,-24},{-24,-24,-24},},
	f={
		 {5,3,1,uv={{96,256},{72,232},{72,256},-1},f=2},
		 {3,8,4,uv={{96,232},{72,256},{96,256},-1},f=2},
		 {7,6,8,uv={{96,232},{72,256},{96,256},-1},f=2},
		 {2,8,6,uv={{96,256},{72,232},{72,256},-1},f=2},
		 {1,4,2,uv={{96,232},{72,256},{96,256},-1},f=2},
		 {5,2,6,uv={{96,232},{72,256},{96,256},-1},f=2},
		 {5,7,3,uv={{96,256},{96,232},{72,232},-1},f=2},
		 {3,7,8,uv={{96,232},{72,232},{72,256},-1},f=2},
		 {7,5,6,uv={{96,232},{72,232},{72,256},-1},f=2},
		 {2,4,8,uv={{96,256},{96,232},{72,232},-1},f=2},
		 {1,3,4,uv={{96,232},{72,232},{72,256},-1},f=2},
		 {5,1,2,uv={{96,232},{72,232},{72,256},-1},f=2},
	}
	},
	{--cube companion (2)
	v={{ 24, 24, 24},{ 24,-24, 24},{ 24, 24,-24},{ 24,-24,-24},{-24, 24, 24},{-24,-24, 24},{-24, 24,-24},{-24,-24,-24},},
	f={
		 {5,3,1,uv={{96,256-24},{72,232-24},{72,256-24},-1},f=2},
		 {3,8,4,uv={{96,232-24},{72,256-24},{96,256-24},-1},f=2},
		 {7,6,8,uv={{96,232-24},{72,256-24},{96,256-24},-1},f=2},
		 {2,8,6,uv={{96,256-24},{72,232-24},{72,256-24},-1},f=2},
		 {1,4,2,uv={{96,232-24},{72,256-24},{96,256-24},-1},f=2},
		 {5,2,6,uv={{96,232-24},{72,256-24},{96,256-24},-1},f=2},
		 {5,7,3,uv={{96,256-24},{96,232-24},{72,232-24},-1},f=2},
		 {3,7,8,uv={{96,232-24},{72,232-24},{72,256-24},-1},f=2},
		 {7,5,6,uv={{96,232-24},{72,232-24},{72,256-24},-1},f=2},
		 {2,4,8,uv={{96,256-24},{96,232-24},{72,232-24},-1},f=2},
		 {1,3,4,uv={{96,232-24},{72,232-24},{72,256-24},-1},f=2},
		 {5,1,2,uv={{96,232-24},{72,232-24},{72,256-24},-1},f=2},
	}
	},
	{ --cube dispenser (3)
		v={{24,24,24},{24,-24,24},{24,24,-24},{24,-24,-24},{-24,24,24},{-24,-24,24},{-24,24,-24},{-24,-24,-24},},
		f={
			{5,3,1,uv={{120,232},{96, 208},{96 ,232},-1},f=3},
			{3,8,4,uv={{120,232},{96, 256},{120,256},-1},f=3},
			{7,6,8,uv={{120,232},{96, 256},{120,256},-1},f=3},
			{2,8,6,uv={{120,232},{96, 208},{96 ,232},-1},f=3},
			{1,4,2,uv={{120,232},{96, 256},{120,256},-1},f=3},
			{5,2,6,uv={{120,232},{96, 256},{120,256},-1},f=3},
			{5,7,3,uv={{120,232},{120,208},{96 ,208},-1},f=3},
			{3,7,8,uv={{120,232},{96, 232},{96 ,256},-1},f=3},
			{7,5,6,uv={{120,232},{96, 232},{96 ,256},-1},f=3},
			{2,4,8,uv={{120,232},{120,208},{96 ,208},-1},f=3},
			{1,3,4,uv={{120,232},{96, 232},{96 ,256},-1},f=3},
			{5,1,2,uv={{120,232},{96, 232},{96 ,256},-1},f=3}}
	},
	{--light bridge (-X) (4)
		v={{-48,4, 48},{ 48,4, 48},{-48,4,-48},{ 48,4,-48}},
		f={{2,1,4,uv={{0,232},{16,232},{0,248}},f=3},{1,4,3,uv={{16,232},{0,248},{16,248}},f=3}}
	},
	{ --light bridge (+X) (5)
		v={{-48,4,-48},{ 48,4,-48},{-48,4, 48},{ 48,4, 48}},
		f={{1,2,3,uv={{0,232},{16,232},{0,248}},f=3},{2,3,4,uv={{16,232},{0,248},{16,248}},f=3}}
	},
	{--light bridge (-Z) (6)
		v={{-48,4,-48},{-48,4, 48},{ 48,4,-48},{ 48,4, 48}},
		f={{2,1,4,uv={{0,232},{16,232},{0,248}},f=3},{1,4,3,uv={{16,232},{0,248},{16,248}},f=3}}
	},
	{--light bridge (+Z) (7)
		v={{ 48,4, 48},{ 48,4,-48},{-48,4, 48},{-48,4,-48}},
		f={{2,1,4,uv={{0,232},{16,232},{0,248}},f=3},{1,4,3,uv={{16,232},{0,248},{16,248}},f=3}}
	},
	{--button -X (8)
		v={
			{6   ,46  ,6   },
			{6   ,0   ,6   },
			{6   ,46  ,-6  },
			{6   ,0   ,-6  },
			{-6  ,51.2,6   },
			{-6  ,0   ,6   },
			{-6  ,51.2,-6  },
			{-6  ,0   ,-6  },
			{-4.5,51.2,-4.5},
			{-4.5,51.2,4.5 },
			{5.5 ,47.2,-4.5},
			{5.5 ,47.2,4.5 },
		},
		f={
			{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},
			{3 ,8 ,4 ,uv={{128,128},{125,132},{128,132},-1},f=2},
			{7 ,6 ,8 ,uv={{128,128},{125,132},{128,132},-1},f=2},
			{1 ,4 ,2 ,uv={{125,132},{128,128},{125,128},-1},f=2},
			{6 ,1 ,2 ,uv={{128,132},{125,128},{125,132},-1},f=2},
			{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},
			{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},
			{3 ,7 ,8 ,uv={{128,128},{125,128},{125,132},-1},f=2},
			{7 ,5 ,6 ,uv={{128,128},{125,128},{125,132},-1},f=2},
			{1 ,3 ,4 ,uv={{125,132},{128,132},{128,128},-1},f=2},
			{6 ,5 ,1 ,uv={{128,132},{128,128},{125,128},-1},f=2},
			{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},
		}
	},
	{--button +X (9)
		v={
			{-6   ,46  ,-6  },
			{-6   ,0   ,-6  },
			{-6   ,46  ,6   },
			{-6   ,0   ,6   },
			{6    ,51.2,-6  },
			{6    ,0   ,-6  },
			{6    ,51.2,6   },
			{6    ,0   ,6   },
			{4.5  ,51.2,4.5 },
			{4.5  ,51.2,-4.5},
			{-5.5 ,47.2,4.5 },
			{-5.5 ,47.2,-4.5},
		},
		f={
			{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},
			{3 ,8 ,4 ,uv={{128,128},{125,132},{128,132},-1},f=2},
			{7 ,6 ,8 ,uv={{128,128},{125,132},{128,132},-1},f=2},
			{1 ,4 ,2 ,uv={{125,132},{128,128},{125,128},-1},f=2},
			{6 ,1 ,2 ,uv={{128,132},{125,128},{125,132},-1},f=2},
			{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},
			{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},
			{3 ,7 ,8 ,uv={{128,128},{125,128},{125,132},-1},f=2},
			{7 ,5 ,6 ,uv={{128,128},{125,128},{125,132},-1},f=2},
			{1 ,3 ,4 ,uv={{125,132},{128,132},{128,128},-1},f=2},
			{6 ,5 ,1 ,uv={{128,132},{128,128},{125,128},-1},f=2},
			{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},
		}
	},
	{--button -Z (10)
		v={
			{-6  ,46  ,6   },
			{-6  ,0   ,6   },
			{6   ,46  ,6   },
			{6   ,0   ,6   },
			{-6  ,51.2,-6  },
			{-6  ,0   ,-6  },
			{6   ,51.2,-6  },
			{6   ,0   ,-6  },
			{4.5 ,51.2,-4.5},
			{-4.5,51.2,-4.5},
			{4.5 ,47.2,5.5 },
			{-4.5,47.2,5.5 },
		},
		f={
			{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},
			{3 ,8 ,4 ,uv={{128,128},{125,132},{128,132},-1},f=2},
			{7 ,6 ,8 ,uv={{128,128},{125,132},{128,132},-1},f=2},
			{1 ,4 ,2 ,uv={{125,132},{128,128},{125,128},-1},f=2},
			{6 ,1 ,2 ,uv={{128,132},{125,128},{125,132},-1},f=2},
			{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},
			{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},
			{3 ,7 ,8 ,uv={{128,128},{125,128},{125,132},-1},f=2},
			{7 ,5 ,6 ,uv={{128,128},{125,128},{125,132},-1},f=2},
			{1 ,3 ,4 ,uv={{125,132},{128,132},{128,128},-1},f=2},
			{6 ,5 ,1 ,uv={{128,132},{128,128},{125,128},-1},f=2},
			{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},
		}
	},
	{--button +Z (11)
		v={
			{6   ,46  ,-6   },
			{6   ,0   ,-6   },
			{-6  ,46  ,-6   },
			{-6  ,0   ,-6   },
			{6   ,51.2,6    },
			{6   ,0   ,6    },
			{-6  ,51.2,6    },
			{-6  ,0   ,6    },
			{-4.5,51.2,4.5  },
			{4.5 ,51.2,4.5  },
			{-4.5,47.2,-5.5 },
			{4.5 ,47.2,-5.5 },
		},
		f={
			{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},
			{3 ,8 ,4 ,uv={{128,128},{125,132},{128,132},-1},f=2},
			{7 ,6 ,8 ,uv={{128,128},{125,132},{128,132},-1},f=2},
			{1 ,4 ,2 ,uv={{125,132},{128,128},{125,128},-1},f=2},
			{6 ,1 ,2 ,uv={{128,132},{125,128},{125,132},-1},f=2},
			{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},
			{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},
			{3 ,7 ,8 ,uv={{128,128},{125,128},{125,132},-1},f=2},
			{7 ,5 ,6 ,uv={{128,128},{125,128},{125,132},-1},f=2},
			{1 ,3 ,4 ,uv={{125,132},{128,132},{128,128},-1},f=2},
			{6 ,5 ,1 ,uv={{128,132},{128,128},{125,128},-1},f=2},
			{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},
		}
	},
	{ --turret -X (12)
		v={
			 {7,0  ,0},
			 {28,27 ,0},
			 {7,27 ,0},
			 {28,0  ,0},
			 {-24,0  ,-19},
			 {-4,27 ,-8},
			 {-24,27 ,-19},
			 {-4,0  ,-8},
			 {-24,0  ,18},
			 {-4,27 ,7},
			 {-24,27 ,18},
			 {-4,0  ,7},
			 {12,41 ,-12},
			 {8,12 ,-9},
			 {-9,67 ,-9},
			 {-12,41 ,-12},
			 {-9,12 ,-9},
			 {0,76 ,0},
			 {-9,67 ,8},
			 {-12,41 ,12},
			 {-9,12 ,8},
			 {8,67 ,8},
			 {12,41 ,12},
			 {8,12 ,8},
			 {8,67 ,-9},
			 {-12,37 ,0},
			 {-12,42 ,4},
			 {-12,42 ,-5},
			 {-12,47 ,0},
			 {12,41 ,-22},
			 {8,12 ,-19},
			 {-9,67 ,-19},
			 {-12,41 ,-22},
			 {-9,12 ,-19},
			 {8,67 ,-19},
			 {-9,67 ,18},
			 {-12,41 ,22},
			 {-9,12 ,18},
			 {8,67 ,18},
			 {12,41 ,22},
			 {8,12 ,18},
			 {0,28 ,20},
			 {0,55 ,20},
			 {0,28 ,-20},
			 {0,55 ,-20},
			 {0,43 ,-22},
			 {0,43 ,21},
		},
		f={
			{3 ,4 ,1 ,uv={{124,138},{120,144},{124,144},-1},f=3},
			{7 ,8 ,5 ,uv={{120,138},{124,144},{120,144},-1},f=3},
			{11,12,9 ,uv={{120,138},{124,144},{120,144},-1},f=3},
			{45,47,46,uv={{124,138},{123,136},{123,138},-1},f=3},
			{44,47,42,uv={{122,138},{123,136},{122,136},-1},f=3},
			{3 ,2 ,4 ,uv={{124,138},{120,138},{120,144},-1},f=3},
			{7 ,6 ,8 ,uv={{120,138},{124,138},{124,144},-1},f=3},
			{11,10,12,uv={{120,138},{124,138},{124,144},-1},f=3},
			{45,43,47,uv={{124,138},{124,136},{123,136},-1},f=3},
			{44,46,47,uv={{122,138},{123,138},{123,136},-1},f=3},
			{25,18,15,uv={{126,138},{128,138},{128,136},-1},f=2},
			{25,16,13,uv={{125,140},{125,140},{126,139},-1},f=2},
			{13,17,14,uv={{125,140},{125,140},{126,139},-1},f=2},
			{15,20,16,uv={{124,138},{124,139},{125,138},-1},f=2},
			{17,20,21,uv={{124,138},{124,139},{125,138},-1},f=2},
			{15,18,19,uv={{124,138},{124,139},{125,138},-1},f=2},
			{20,22,23,uv={{125,140},{125,140},{126,139},-1},f=2},
			{21,23,24,uv={{125,140},{125,140},{126,139},-1},f=2},
			{19,18,22,uv={{124,138},{124,139},{125,138},-1},f=2},
			{22,18,25,uv={{124,138},{124,139},{125,138},-1},f=2},
			{22,13,23,uv={{124,138},{124,139},{125,138},-1},f=2},
			{23,14,24,uv={{124,138},{124,139},{125,138},-1},f=2},
			{25,15,16,uv={{125,140},{125,140},{126,139},-1},f=2},
			{13,16,17,uv={{125,140},{125,140},{126,139},-1},f=2},
			{15,19,20,uv={{124,138},{124,139},{125,138},-1},f=2},
			{17,16,20,uv={{124,138},{124,139},{125,138},-1},f=2},
			{20,19,22,uv={{125,140},{125,140},{126,139},-1},f=2},
			{21,20,23,uv={{125,140},{125,140},{126,139},-1},f=2},
			{22,25,13,uv={{124,138},{124,139},{125,138},-1},f=2},
			{23,13,14,uv={{124,138},{124,139},{125,138},-1},f=2},
			{35,33,30,uv={{128,136},{124,140},{128,140},-1},f=3},
			{30,34,31,uv={{128,143},{124,140},{124,143},-1},f=3},
			{36,40,37,uv={{128,136},{124,140},{128,140},-1},f=3},
			{38,40,41,uv={{128,143},{124,140},{124,143},-1},f=3},
			{35,32,33,uv={{128,136},{124,136},{124,140},-1},f=3},
			{30,33,34,uv={{128,143},{128,140},{124,140},-1},f=3},
			{36,39,40,uv={{128,136},{124,136},{124,140},-1},f=3},
			{38,37,40,uv={{128,143},{128,140},{124,140},-1},f=3},
			{29,26,28,uv={{122,138},{120,136},{120,138},-1},f=2},
			{29,27,26,uv={{122,138},{122,136},{120,136},-1},f=2},
		}
	},
	{ --turret +X (13)
		v={
			 {-7,0,0},
			 {-28,27,0},
			 {-7,27,0},
			 {-28,0,0},
			 {24,0,19},
			 {4,27,8},
			 {24,27,19},
			 {4,0,8},
			 {24,0,-18},
			 {4,27,-7},
			 {24,27,-18},
			 {4,0,-7},
			 {-12,41,12},
			 {-8,12,9},
			 {9,67,9},
			 {12,41,12},
			 {9,12,9},
			 {0,76,0},
			 {9,67,-8},
			 {12,41,-12},
			 {9,12,-8},
			 {-8,67,-8},
			 {-12,41,-12},
			 {-8,12,-8},
			 {-8,67,9},
			 {12,37,0},
			 {12,42,-4},
			 {12,42,5},
			 {12,47,0},
			 {-12,41,22},
			 {-8,12,19},
			 {9,67,19},
			 {12,41,22},
			 {9,12,19},
			 {-8,67,19},
			 {9,67,-18},
			 {12,41,-22},
			 {9,12,-18},
			 {-8,67,-18},
			 {-12,41,-22},
			 {-8,12,-18},
			 {0,28,-20},
			 {0,55,-20},
			 {0,28,20},
			 {0,55,20},
			 {0,43,22},
			 {0,43,-21},
		},
		f={
			{3 ,4 ,1 ,uv={{124,138},{120,144},{124,144},-1},f=3},
			{7 ,8 ,5 ,uv={{120,138},{124,144},{120,144},-1},f=3},
			{11,12,9 ,uv={{120,138},{124,144},{120,144},-1},f=3},
			{45,47,46,uv={{124,138},{123,136},{123,138},-1},f=3},
			{44,47,42,uv={{122,138},{123,136},{122,136},-1},f=3},
			{3 ,2 ,4 ,uv={{124,138},{120,138},{120,144},-1},f=3},
			{7 ,6 ,8 ,uv={{120,138},{124,138},{124,144},-1},f=3},
			{11,10,12,uv={{120,138},{124,138},{124,144},-1},f=3},
			{45,43,47,uv={{124,138},{124,136},{123,136},-1},f=3},
			{44,46,47,uv={{122,138},{123,138},{123,136},-1},f=3},
			{25,18,15,uv={{126,138},{128,138},{128,136},-1},f=2},
			{25,16,13,uv={{125,140},{125,140},{126,139},-1},f=2},
			{13,17,14,uv={{125,140},{125,140},{126,139},-1},f=2},
			{15,20,16,uv={{124,138},{124,139},{125,138},-1},f=2},
			{17,20,21,uv={{124,138},{124,139},{125,138},-1},f=2},
			{15,18,19,uv={{124,138},{124,139},{125,138},-1},f=2},
			{20,22,23,uv={{125,140},{125,140},{126,139},-1},f=2},
			{21,23,24,uv={{125,140},{125,140},{126,139},-1},f=2},
			{19,18,22,uv={{124,138},{124,139},{125,138},-1},f=2},
			{22,18,25,uv={{124,138},{124,139},{125,138},-1},f=2},
			{22,13,23,uv={{124,138},{124,139},{125,138},-1},f=2},
			{23,14,24,uv={{124,138},{124,139},{125,138},-1},f=2},
			{25,15,16,uv={{125,140},{125,140},{126,139},-1},f=2},
			{13,16,17,uv={{125,140},{125,140},{126,139},-1},f=2},
			{15,19,20,uv={{124,138},{124,139},{125,138},-1},f=2},
			{17,16,20,uv={{124,138},{124,139},{125,138},-1},f=2},
			{20,19,22,uv={{125,140},{125,140},{126,139},-1},f=2},
			{21,20,23,uv={{125,140},{125,140},{126,139},-1},f=2},
			{22,25,13,uv={{124,138},{124,139},{125,138},-1},f=2},
			{23,13,14,uv={{124,138},{124,139},{125,138},-1},f=2},
			{35,33,30,uv={{128,136},{124,140},{128,140},-1},f=3},
			{30,34,31,uv={{128,143},{124,140},{124,143},-1},f=3},
			{36,40,37,uv={{128,136},{124,140},{128,140},-1},f=3},
			{38,40,41,uv={{128,143},{124,140},{124,143},-1},f=3},
			{35,32,33,uv={{128,136},{124,136},{124,140},-1},f=3},
			{30,33,34,uv={{128,143},{128,140},{124,140},-1},f=3},
			{36,39,40,uv={{128,136},{124,136},{124,140},-1},f=3},
			{38,37,40,uv={{128,143},{128,140},{124,140},-1},f=3},
			{29,26,28,uv={{122,138},{120,136},{120,138},-1},f=2},
			{29,27,26,uv={{122,138},{122,136},{120,136},-1},f=2},
		}
	},
	{ --turret -Z (14)
		v={
			{0  ,0  ,7},
			{0  ,27 ,28},
			{0  ,27 ,7},
			{0  ,0  ,28},
			{19 ,0  ,-24},
			{8  ,27 ,-4},
			{19 ,27 ,-24},
			{8  ,0  ,-4},
			{-18,0  ,-24},
			{-7 ,27 ,-4},
			{-18,27 ,-24},
			{-7 ,0  ,-4},
			{12 ,41 ,12},
			{9  ,12 ,8},
			{9  ,67 ,-9},
			{12 ,41 ,-12},
			{9  ,12 ,-9},
			{0  ,76 ,0},
			{-8 ,67 ,-9},
			{-12,41 ,-12},
			{-8 ,12 ,-9},
			{-8 ,67 ,8},
			{-12,41 ,12},
			{-8 ,12 ,8},
			{9  ,67 ,8},
			{0  ,37 ,-12},
			{-4 ,42 ,-12},
			{5  ,42 ,-12},
			{0  ,47 ,-12},
			{22 ,41 ,12},
			{19 ,12 ,8},
			{19 ,67 ,-9},
			{22 ,41 ,-12},
			{19 ,12 ,-9},
			{19 ,67 ,8},
			{-18,67 ,-9},
			{-22,41 ,-12},
			{-18,12 ,-9},
			{-18,67 ,8},
			{-22,41 ,12},
			{-18,12 ,8},
			{-20,28 ,0},
			{-20,55 ,0},
			{20 ,28 ,0},
			{20 ,55 ,0},
			{22 ,43 ,0},
			{-21,43 ,0},
		},
		f={
			{3 ,4 ,1 ,uv={{124,138},{120,144},{124,144},-1},f=3},
			{7 ,8 ,5 ,uv={{120,138},{124,144},{120,144},-1},f=3},
			{11,12,9 ,uv={{120,138},{124,144},{120,144},-1},f=3},
			{45,47,46,uv={{124,138},{123,136},{123,138},-1},f=3},
			{44,47,42,uv={{122,138},{123,136},{122,136},-1},f=3},
			{3 ,2 ,4 ,uv={{124,138},{120,138},{120,144},-1},f=3},
			{7 ,6 ,8 ,uv={{120,138},{124,138},{124,144},-1},f=3},
			{11,10,12,uv={{120,138},{124,138},{124,144},-1},f=3},
			{45,43,47,uv={{124,138},{124,136},{123,136},-1},f=3},
			{44,46,47,uv={{122,138},{123,138},{123,136},-1},f=3},
			{25,18,15,uv={{126,138},{128,138},{128,136},-1},f=2},
			{25,16,13,uv={{125,140},{125,140},{126,139},-1},f=2},
			{13,17,14,uv={{125,140},{125,140},{126,139},-1},f=2},
			{15,20,16,uv={{124,138},{124,139},{125,138},-1},f=2},
			{17,20,21,uv={{124,138},{124,139},{125,138},-1},f=2},
			{15,18,19,uv={{124,138},{124,139},{125,138},-1},f=2},
			{20,22,23,uv={{125,140},{125,140},{126,139},-1},f=2},
			{21,23,24,uv={{125,140},{125,140},{126,139},-1},f=2},
			{19,18,22,uv={{124,138},{124,139},{125,138},-1},f=2},
			{22,18,25,uv={{124,138},{124,139},{125,138},-1},f=2},
			{22,13,23,uv={{124,138},{124,139},{125,138},-1},f=2},
			{23,14,24,uv={{124,138},{124,139},{125,138},-1},f=2},
			{25,15,16,uv={{125,140},{125,140},{126,139},-1},f=2},
			{13,16,17,uv={{125,140},{125,140},{126,139},-1},f=2},
			{15,19,20,uv={{124,138},{124,139},{125,138},-1},f=2},
			{17,16,20,uv={{124,138},{124,139},{125,138},-1},f=2},
			{20,19,22,uv={{125,140},{125,140},{126,139},-1},f=2},
			{21,20,23,uv={{125,140},{125,140},{126,139},-1},f=2},
			{22,25,13,uv={{124,138},{124,139},{125,138},-1},f=2},
			{23,13,14,uv={{124,138},{124,139},{125,138},-1},f=2},
			{35,33,30,uv={{128,136},{124,140},{128,140},-1},f=3},
			{30,34,31,uv={{128,143},{124,140},{124,143},-1},f=3},
			{36,40,37,uv={{128,136},{124,140},{128,140},-1},f=3},
			{38,40,41,uv={{128,143},{124,140},{124,143},-1},f=3},
			{35,32,33,uv={{128,136},{124,136},{124,140},-1},f=3},
			{30,33,34,uv={{128,143},{128,140},{124,140},-1},f=3},
			{36,39,40,uv={{128,136},{124,136},{124,140},-1},f=3},
			{38,37,40,uv={{128,143},{128,140},{124,140},-1},f=3},
			{29,26,28,uv={{122,138},{120,136},{120,138},-1},f=2},
			{29,27,26,uv={{122,138},{122,136},{120,136},-1},f=2},
		}
	},
	{ --turret +Z (15)
		v={
			 {0,0  ,-7 },
			 {0,27 ,-28},
			 {0,27 ,-7 },
			 {0,0  ,-28},
			 {-19,0  ,24 },
			 {-8,27 ,4  },
			 {-19,27 ,24 },
			 {-8,0  ,4  },
			 {18,0  ,24 },
			 {7,27 ,4  },
			 {18,27 ,24 },
			 {7,0  ,4  },
			 {-12,41 ,-12},
			 {-9,12 ,-8 },
			 {-9,67 ,9  },
			 {-12,41 ,12 },
			 {-9,12 ,9  },
			 {0,76 ,0  },
			 {8,67 ,9  },
			 {12,41 ,12 },
			 {8,12 ,9  },
			 {8,67 ,-8 },
			 {12,41 ,-12},
			 {8,12 ,-8 },
			 {-9,67 ,-8 },
			 {0,37 ,12 },
			 {4,42 ,12 },
			 {-5,42 ,12 },
			 {0,47 ,12 },
			 {-22,41 ,-12},
			 {-19,12 ,-8 },
			 {-19,67 ,9  },
			 {-22,41 ,12 },
			 {-19,12 ,9  },
			 {-19,67 ,-8 },
			 {18,67 ,9  },
			 {22,41 ,12 },
			 {18,12 ,9  },
			 {18,67 ,-8 },
			 {22,41 ,-12},
			 {18,12 ,-8 },
			 {20,28 ,0  },
			 {20,55 ,0  },
			 {-20,28 ,0  },
			 {-20,55 ,0  },
			 {-22,43 ,0  },
			 {21,43 ,0  },
		},
		f={
			{3 ,4 ,1 ,uv={{124,138},{120,144},{124,144},-1},f=3},
			{7 ,8 ,5 ,uv={{120,138},{124,144},{120,144},-1},f=3},
			{11,12,9 ,uv={{120,138},{124,144},{120,144},-1},f=3},
			{45,47,46,uv={{124,138},{123,136},{123,138},-1},f=3},
			{44,47,42,uv={{122,138},{123,136},{122,136},-1},f=3},
			{3 ,2 ,4 ,uv={{124,138},{120,138},{120,144},-1},f=3},
			{7 ,6 ,8 ,uv={{120,138},{124,138},{124,144},-1},f=3},
			{11,10,12,uv={{120,138},{124,138},{124,144},-1},f=3},
			{45,43,47,uv={{124,138},{124,136},{123,136},-1},f=3},
			{44,46,47,uv={{122,138},{123,138},{123,136},-1},f=3},
			{25,18,15,uv={{126,138},{128,138},{128,136},-1},f=2},
			{25,16,13,uv={{125,140},{125,140},{126,139},-1},f=2},
			{13,17,14,uv={{125,140},{125,140},{126,139},-1},f=2},
			{15,20,16,uv={{124,138},{124,139},{125,138},-1},f=2},
			{17,20,21,uv={{124,138},{124,139},{125,138},-1},f=2},
			{15,18,19,uv={{124,138},{124,139},{125,138},-1},f=2},
			{20,22,23,uv={{125,140},{125,140},{126,139},-1},f=2},
			{21,23,24,uv={{125,140},{125,140},{126,139},-1},f=2},
			{19,18,22,uv={{124,138},{124,139},{125,138},-1},f=2},
			{22,18,25,uv={{124,138},{124,139},{125,138},-1},f=2},
			{22,13,23,uv={{124,138},{124,139},{125,138},-1},f=2},
			{23,14,24,uv={{124,138},{124,139},{125,138},-1},f=2},
			{25,15,16,uv={{125,140},{125,140},{126,139},-1},f=2},
			{13,16,17,uv={{125,140},{125,140},{126,139},-1},f=2},
			{15,19,20,uv={{124,138},{124,139},{125,138},-1},f=2},
			{17,16,20,uv={{124,138},{124,139},{125,138},-1},f=2},
			{20,19,22,uv={{125,140},{125,140},{126,139},-1},f=2},
			{21,20,23,uv={{125,140},{125,140},{126,139},-1},f=2},
			{22,25,13,uv={{124,138},{124,139},{125,138},-1},f=2},
			{23,13,14,uv={{124,138},{124,139},{125,138},-1},f=2},
			{35,33,30,uv={{128,136},{124,140},{128,140},-1},f=3},
			{30,34,31,uv={{128,143},{124,140},{124,143},-1},f=3},
			{36,40,37,uv={{128,136},{124,140},{128,140},-1},f=3},
			{38,40,41,uv={{128,143},{124,140},{124,143},-1},f=3},
			{35,32,33,uv={{128,136},{124,136},{124,140},-1},f=3},
			{30,33,34,uv={{128,143},{128,140},{124,140},-1},f=3},
			{36,39,40,uv={{128,136},{124,136},{124,140},-1},f=3},
			{38,37,40,uv={{128,143},{128,140},{124,140},-1},f=3},
			{29,26,28,uv={{122,138},{120,136},{120,138},-1},f=2},
			{29,27,26,uv={{122,138},{122,136},{120,136},-1},f=2},
		}
	},
}

local s = { --sounds
t1=0, --sad story about a lonely variable in one table
}

local world_size={12,4,12}
world_size[4]=world_size[2]*world_size[3]
world_size[5]=world_size[1]*world_size[2]*world_size[3]
--world
local draw={
	objects={
		c={}, --cubes
		cd={}, --cube dispensers
		lb={}, --light bridges
		b={}, --buttons
		t={}, --turrets
	},
	world={v={},f={},sp={}}, --main world
	world_bp={f={}}, --the world for the blue portal
	world_op={f={}}, --the world for the orange portal
	map={},
	pr={}, --particles
	pr_g={}, --particle generator (for a light bridge)
	p={nil,nil}, --portals
	p_verts={}, --portal vertices
	lg={}--light bridge generators
}

local fps_={t1=0,t2=0,t3=0,t4=0,t5=0,t6=0,t7=0,t8=0,t9=0}

--maps
local maps={[0]={},[1]={},[2]={}}

--[[
	0 set of levels - system levels
	1 set of levels - levels of the main game
	2 set of levels - Levels for skilltest
]]

maps[0][2]={ --main gameroom
	w={ --table for walls
	--{X, Y, Z, angle, face, type}
	},
	o={ --table for objects
	 --{X, Y, Z, type, [additional parameters]}
	 {800,0,900,13},
	 {800,600,900,2},
	},
	p={}, --table for portals (leave empty if the portals are not needed)
	lg={{0,0,1,1,2}}, --light bridge generators
	lift={{0,0,0,2},{0,0,10,0}}, --Initial and final elevator (X Y Z angle) [0 -X, 1 -Z 2 +X, 3 +Z]
	music=0 --Music ID for this level
}

maps[0][1]={ --world from the main menu
w={
	{2,0,2,1,3,4},
	{4,0,2,1,1,5},
	{2,0,3,1,3,4},
	{4,0,3,1,1,2},
	{2,0,2,3,3,4},
	{3,0,2,3,3,4},
	{2,0,4,3,3,4},
	{3,0,4,3,3,4},
	{4,0,1,1,1,2},
	{4,0,0,1,1,6},
	{5,0,5,1,1,13},
	{5,0,4,1,1,14},
	{4,0,4,3,1,2},
	--
	{0,0,0,1,2,2},{0,0,1,1,2,2},{0,0,2,1,2,2},{0,0,3,1,2,2},{0,0,4,1,2,2},{0,0,5,1,2,2},
	--
	{0,0,6,3,2,2},{1,0,6,3,2,2},{2,0,6,3,2,2},{3,0,6,3,2,2},{4,0,6,3,2,2},
	--
	{0,0,0,3,1,2},{1,0,0,3,1,2},{2,0,0,3,1,2},{3,0,0,3,1,2},
	--
	{0,0,0,2,2,1},{1,0,0,2,2,1},{2,0,0,2,2,1},{3,0,0,2,2,1},
	{0,0,1,2,2,1},{1,0,1,2,2,1},{2,0,1,2,2,1},{3,0,1,2,2,1},
	{0,0,2,2,2,1},{1,0,2,2,2,1},{2,0,2,2,2,1},{3,0,2,2,2,1},
	{0,0,3,2,2,1},{1,0,3,2,2,1},{2,0,3,2,2,1},{3,0,3,2,2,1},
	{0,0,4,2,2,1},{1,0,4,2,2,1},{2,0,4,2,2,1},{3,0,4,2,2,1},{4,0,4,2,2,1},
	{0,0,5,2,2,1},{1,0,5,2,2,1},{2,0,5,2,2,1},{3,0,5,2,2,1},{4,0,5,2,2,1},
	--
	{0,1,0,2,1,2},{1,1,0,2,1,2},{2,1,0,2,1,2},{3,1,0,2,1,2},
	{0,1,1,2,1,2},{1,1,1,2,1,2},{2,1,1,2,1,2},{3,1,1,2,1,2},
	{0,1,2,2,1,2},{1,1,2,2,1,2},{2,1,2,2,1,2},{3,1,2,2,1,2},
	{0,1,3,2,1,2},{1,1,3,2,1,2},{2,1,3,2,1,2},{3,1,3,2,1,2},
	{0,1,4,2,1,2},{1,1,4,2,1,2},{2,1,4,2,1,2},{3,1,4,2,1,2},{4,1,4,2,1,2},
	{0,1,5,2,1,2},{1,1,5,2,1,2},{2,1,5,2,1,2},{3,1,5,2,1,2},{4,1,5,2,1,2},

},
o={},
p={},
lg={},
lift={nil,nil},
music=-1,
}

for x=0,10 do
	for y=0,2 do
		maps[0][2].w[#maps[0][2].w+1]={x,y,0 ,3,1,R(1,2)}
		maps[0][2].w[#maps[0][2].w+1]={x,y,11,3,2,R(1,2)}
		maps[0][2].w[#maps[0][2].w+1]={0 ,y,x,1,2,R(1,2)}
		maps[0][2].w[#maps[0][2].w+1]={11,y,x,1,1,R(1,2)}
	end

	for z=0,10 do
		maps[0][2].w[#maps[0][2].w+1]={x,0,z,2,2,1}
		if R()>0.5 then maps[0][2].w[#maps[0][2].w+1]={x,2,z,2,3,R(1,5)} end
	end
end

maps[0][2].w[#maps[0][2].w+1]={0,0,1,1,2,9}

maps[0][2].w[#maps[0][2].w+1]={2,0,0,3,1,8}
maps[0][2].w[#maps[0][2].w+1]={3,0,11,3,2,9}
maps[0][2].w[#maps[0][2].w+1]={0,1,2,1,2,16}
maps[0][2].w[#maps[0][2].w+1]={0,1,3,1,2,17}
maps[0][2].w[#maps[0][2].w+1]={0,0,6,3,3,12}
maps[0][2].w[#maps[0][2].w+1]={1,0,6,3,3,11}
maps[0][2].w[#maps[0][2].w+1]={2,0,5,1,1,2}
maps[0][2].w[#maps[0][2].w+1]={3,0,5,1,2,2}
maps[0][2].w[#maps[0][2].w+1]={2,0,6,3,1,2}
maps[0][2].w[#maps[0][2].w+1]={2,0,5,3,2,2}
maps[0][2].w[#maps[0][2].w+1]={2,1,5,2,2,2}
maps[0][2].w[#maps[0][2].w+1]={3,0,6,3,3,14}
maps[0][2].w[#maps[0][2].w+1]={4,0,6,3,3,13}
maps[0][2].w[#maps[0][2].w+1]={5,0,6,3,3,1}
maps[0][2].w[#maps[0][2].w+1]={6,0,6,3,3,15}
maps[0][2].w[#maps[0][2].w+1]={7,0,6,3,3,3}
maps[0][2].w[#maps[0][2].w+1]={8,0,6,3,3,3}
maps[0][2].w[#maps[0][2].w+1]={9,0,6,3,3,4}
maps[0][2].w[#maps[0][2].w+1]={10,0,6,3,3,7}
maps[0][2].w[#maps[0][2].w+1]={6,0,5,2,3,8}
maps[0][2].w[#maps[0][2].w+1]={6,0,6,2,3,8}
maps[0][2].w[#maps[0][2].w+1]={3,0,5,2,3,8}

--song text
local s_t={
	"This is one of the",
	"few games that took",
	"us weeks of hard",
	"work to develop.",
	"    ",
	"Yes, we are not the",
	"first to make portal",
	"3D in TIC-80",
	"(although in fact we",
	"were the first to do",
	"it) but we are the",
	"first to turn it into",
	"a full-fledged game",
	"with a bunch of",
	"interesting mechanics,",
	"putting our soul into",
	"the development of",
	"this game.",
	"    ",
	"We hope you enjoyed",
	"this game and it",
	"deserves a like,",
	"we really tried",
	"very hard.",
	"    ",
}

local s_t2={1,1} --some data to display the text above
--

local function addp(x,y,z,vx,vy,vz,lifetime,color) --add particle
	draw.pr[#draw.pr+1]={x=x,y=y,z=z,vx=vx,vy=vy,vz=vz,lt=lifetime,t=0,c=color}
end
--sprite editor

local function setpix(sx,sy,color)
	local id=sx//8+sy//8*16
	local adr=sx%8+sy%8*8
	poke4(0x8000+id*64+adr,color)
end

local function getpix(sx,sy)
	local id=sx//8+sy//8*16
	local adr=sx%8+sy%8*8
	return peek4(0x8000+id*64+adr)
end

local b_f={} --Texture for the blue field (It is necessary for optimization)

for y0=0,31 do
	b_f[y0]={}
	local c=false
	for x0=0,23 do
		local color1=getpix(x0+24,y0+32)
		local color2=getpix((x0+23)%24+24,y0+32)

		if color1~=15 then b_f[y0][3]=color1 c=true end
		if color1~=color2 then
			if color1==15 then b_f[y0][1]=x0 else b_f[y0][2]=x0 end
		end
	end

	b_f[y0].d=c
end

--collision

local function coll(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4) --collision of two cubes
	-- x1,x2=min(x1,x2),max(x1,x2)
	-- y1,y2=min(y1,y2),max(y1,y2)
	-- z1,z2=min(z1,z2),max(z1,z2)

	-- x3,x4=min(x3,x4),max(x3,x4)
	-- y3,y4=min(y3,y4),max(y3,y4)
	-- z3,z4=min(z3,z4),max(z3,z4)

	return (x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3 and z1 < z4 and z2 > z3)
end

local function min_abs(a, b)
	if abs(a) < abs(b) then return a else return b end
end

local function coll_shift(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, axis)
	if not coll(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4) then
		return 0
	end

	if axis == 1 then
		return min_abs(x3 - x2, x4 - x1)
	elseif axis == 2 then
		return min_abs(y3 - y2, y4 - y1)
	elseif axis == 3 then
		return min_abs(z3 - z2, z4 - z1)
	end
end

local function raycast(x1,y1,z1, x2,y2,z2, hitwalls,hitfloors, precise) -- walk along a segment, checking whether it collides with the walls
	-- convert to tile space
	x1, y1, z1, x2, y2, z2 = x1 / 96, y1 / 128, z1 / 96, x2 / 96, y2 / 128, z2 / 96
	-- DDA, loosely based on https://lodev.org/cgtutor/raycasting.html
	-- segment direction
	local dirx, diry, dirz = x2-x1, y2-y1, z2-z1
	-- length of one step along axes (only relative)
	-- n/0 = inf, which is fine for this algorithm
	local lx, ly, lz = abs(1 / dirx), abs(1 / diry), abs(1 / dirz)
	-- full tile step, matching direction with the segment
	local sx, sy, sz
	-- offset, for handling negative facing
	local ox, oy, oz
	-- current tile (offset if facing positive)
	local x, y, z = F(x1), F(y1), F(z1)
	-- distance to next tile in each axis
	local tx, ty, tz = (x1 - x) * lx, (y1 - y) * ly, (z1 - z) * lz
	if dirx < 0 then
		sx, ox = -1, 1
	else
		sx, ox = 1, 0
		tx = lx - tx
	end
	if diry < 0 then
		sy, oy = -1, 1
	else
		sy, oy = 1, 0
		ty = ly - ty
	end
	if dirz < 0 then
		sz, oz = -1, 1
	else
		sz, oz = 1, 0
		tz = lz - tz
	end
	while true do
		if tx < ty and tx < tz then
			x, tx = x + sx, tx + lx
			if (x + ox) * sx > x2 * sx or (x + ox) < 0 or (x + ox) > world_size[1] - 1 then
				return
			elseif hitwalls[draw.map[1][x + ox][y][z][2]] then
				if precise then
					local ratio = (x + ox - x1) / dirx
					return (x + ox) * 96, (y1 + diry * ratio) * 128, (z1 + dirz * ratio) * 96, 1
				else
					return x + ox, y, z, 1
				end
			elseif x < 0 then
				return
			end
		elseif ty < tz then
			y, ty = y + sy, ty + ly
			if (y + oy) * sy > y2 * sy or (y + oy) < 0 or (y + oy) > world_size[2] - 1 then
				return
			elseif hitfloors[draw.map[2][x][y + oy][z][2]] then
				if precise then
					local ratio = (y + oy - y1) / diry
					return (x1 + dirx * ratio) * 96, (y + oy) * 128, (z1 + dirz * ratio) * 96, 1
				else
					return x, y + oy, z, 2
				end
			elseif y < 0 then
				return
			end
		else
			z, tz = z + sz, tz + lz
			if (z + oz) * sz > z2 * sz or (z + oz) < 0 or (z + oz) > world_size[3] - 1 then
				return
			elseif hitwalls[draw.map[3][x][y][z + oz][2]] then
				if precise then
					local ratio = (z + oz - z1) / dirz
					return (x1 + dirx * ratio) * 96, (y1 + diry * ratio) * 128, (z + oz) * 96, 1
				else
					return x, y, z + oz, 3
				end
			elseif z < 0 then
				return
			end
		end
	end
end

function unitic.update(draw_portal,p_id)
	--writing all polygons in unitic.poly
	unitic.poly = { v = {}, f = {}, sp = {} }
	unitic.obj  = {}
	unitic.p    = {}
	--world--
	for ind = 1, #draw.world.v do
		unitic.poly.v[ind] = { draw.world.v[ind][1], draw.world.v[ind][2], draw.world.v[ind][3] }
	end
	--faces
	if draw_portal==nil then
		for ind=1,#draw.world.f do unitic.poly.f[ind]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
	elseif draw_portal and p_id==1 then
		for ind=1,#draw.world_bp.f do unitic.poly.f[ind]={draw.world_bp.f[ind][1],draw.world_bp.f[ind][2],draw.world_bp.f[ind][3],f=draw.world_bp.f[ind].f,uv=draw.world_bp.f[ind].uv} end
	elseif draw_portal and p_id==2 then
		for ind=1,#draw.world_op.f do unitic.poly.f[ind]={draw.world_op.f[ind][1],draw.world_op.f[ind][2],draw.world_op.f[ind][3],f=draw.world_op.f[ind].f,uv=draw.world_op.f[ind].uv} end
	else
		error("unknown function inputs | "..draw_portal.." "..p_id)
	end
	--objects (1)--
	local f1={{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},{3 ,8 ,4 ,uv={{128,128},{125,132},{128,132},-1},f=2},{7 ,6 ,8 ,uv={{128,128},{125,132},{128,132},-1},f=2},{1 ,4 ,2 ,uv={{125,132},{128,128},{125,128},-1},f=2},{6 ,1 ,2 ,uv={{128,132},{125,128},{125,132},-1},f=2},{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},{3 ,7 ,8 ,uv={{128,128},{125,128},{125,132},-1},f=2},{7 ,5 ,6 ,uv={{128,128},{125,128},{125,132},-1},f=2},{1 ,3 ,4 ,uv={{125,132},{128,132},{128,128},-1},f=2},{6 ,5 ,1 ,uv={{128,132},{128,128},{125,128},-1},f=2},{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},}
	local f2={{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},{3 ,8 ,4 ,uv={{128,132},{125,136},{128,136},-1},f=2},{7 ,6 ,8 ,uv={{128,132},{125,136},{128,136},-1},f=2},{1 ,4 ,2 ,uv={{125,136},{128,132},{125,132},-1},f=2},{6 ,1 ,2 ,uv={{128,136},{125,132},{125,136},-1},f=2},{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},{3 ,7 ,8 ,uv={{128,132},{125,132},{125,136},-1},f=2},{7 ,5 ,6 ,uv={{128,132},{125,132},{125,136},-1},f=2},{1 ,3 ,4 ,uv={{125,136},{128,136},{128,132},-1},f=2},{6 ,5 ,1 ,uv={{128,136},{128,132},{125,132},-1},f=2},{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},}
	
	local i2=0
	for i=1,#draw.objects.c  do i2=i2+1 unitic.obj[i2]=draw.objects.c [i] end
	for i=1,#draw.objects.cd do i2=i2+1 unitic.obj[i2]=draw.objects.cd[i] end
	for i=1,#draw.objects.lb do i2=i2+1 unitic.obj[i2]=draw.objects.lb[i] end
	for i=1,#draw.objects.b  do
		if draw.objects.b[i].s and draw.objects.b[i].tick then draw.objects.b[i].model.f=f2 elseif draw.objects.b[i].tick then draw.objects.b[i].model.f=f1 end
		i2=i2+1 unitic.obj[i2]=draw.objects.b[i]
	end
	for i=1,#draw.objects.t do i2=i2+1 unitic.obj[i2]=draw.objects.t[i] end
	--objects (2)--
	local i2=#unitic.poly.f

	for ind1 = 1, #unitic.obj do
		if unitic.obj[ind1].draw then
			local vt=#unitic.poly.v
			for ind2=1,#unitic.obj[ind1].model.v do
				local px=unitic.obj[ind1].model.v[ind2][1]+unitic.obj[ind1].x
				local py=unitic.obj[ind1].model.v[ind2][2]+unitic.obj[ind1].y
				local pz=unitic.obj[ind1].model.v[ind2][3]+unitic.obj[ind1].z
				unitic.poly.v[#unitic.poly.v+1]={px,py,pz}
			end
			for ind2=1,#unitic.obj[ind1].model.f do
				i2=i2+1
				unitic.poly.f[i2]={unitic.obj[ind1].model.f[ind2][1]+vt, unitic.obj[ind1].model.f[ind2][2]+vt, unitic.obj[ind1].model.f[ind2][3]+vt, f=unitic.obj[ind1].model.f[ind2].f,uv={x={unitic.obj[ind1].model.f[ind2].uv[1][1],unitic.obj[ind1].model.f[ind2].uv[2][1],unitic.obj[ind1].model.f[ind2].uv[3][1]},y={unitic.obj[ind1].model.f[ind2].uv[1][2],unitic.obj[ind1].model.f[ind2].uv[2][2],unitic.obj[ind1].model.f[ind2].uv[3][2]}}}
			end
		end
	end
	--rotate all polygons
	local txsin = math.sin(cam.tx)
	local txcos = math.cos(cam.tx)
	local tysin = math.sin(-cam.ty)
	local tycos = math.cos(-cam.ty)

	for ind = 1, #unitic.poly.v do
		local a1 = unitic.poly.v[ind][1] - cam.x
		local b1 = unitic.poly.v[ind][2] - cam.y
		local c1 = unitic.poly.v[ind][3] - cam.z

		local c2 = c1 * tycos - a1 * tysin

		local a3 = c1 * tysin + a1 * tycos
		local b3 = b1 * txcos - c2 * txsin
		local c3 = b1 * txsin + c2 * txcos
		local c4 = c3
		if c4>-0.001 then c4=-0.001 end
		local z0 = unitic.fov / c4 --this saves one division (very important optimization)

		local x0 = a3 * z0 + 120
		local y0 = b3 * z0 + 68

		unitic.poly.v[ind][1]=x0
		unitic.poly.v[ind][2]=y0
		unitic.poly.v[ind][3]=-c4
		unitic.poly.v[ind][4]=c3>0
	end
	--points for debug
	for ind = 1, #draw.world.sp do
		local a1 = draw.world.sp[ind][1] - cam.x
		local b1 = draw.world.sp[ind][2] - cam.y
		local c1 = draw.world.sp[ind][3] - cam.z

		local c2 = c1 * tycos - a1 * tysin

		local a3 = c1 * tysin + a1 * tycos
		local b3 = b1 * txcos - c2 * txsin
		local c3 = b1 * txsin + c2 * txcos
		if c3>-0.001 then c3=-0.001 end

		unitic.poly.sp[ind]={a3,b3,c3}
	end
	--particles
	for ind = 1, #draw.pr do
		local a1 = draw.pr[ind].x - cam.x
		local b1 = draw.pr[ind].y - cam.y
		local c1 = draw.pr[ind].z - cam.z

		local c2 = c1 * tycos - a1 * tysin

		local x0 = c1 * tysin + a1 * tycos
		local y0 = b1 * txcos - c2 * txsin
		local z0 = b1 * txsin + c2 * txcos

		local draw_p=false
		if z0<0 then draw_p=true end

		if z0>-0.001 then z0=-0.001 end

		local z1 = unitic.fov / z0 --this saves one division (very important optimization)

		local x1 = x0 * z1 + 120
		local y1 = y0 * z1 + 68

		unitic.p[ind]={x1, y1, -z0, draw_p, draw.pr[ind].c}
	end
end

function unitic.update_pr() --update particles
	local i=0 if #draw.pr~=0 then
	repeat
		i=i+1

		draw.pr[i].x = draw.pr[i].x+draw.pr[i].vx
		draw.pr[i].y = draw.pr[i].y+draw.pr[i].vy
		draw.pr[i].z = draw.pr[i].z+draw.pr[i].vz

		draw.pr[i].t = draw.pr[i].t+1

		if draw.pr[i].t==draw.pr[i].lt then table.remove(draw.pr,i) i=i-1 end
	until i>=#draw.pr end
end

function unitic.draw()
	for i = 1, #unitic.poly.f do

		local p2d = {
			x = { unitic.poly.v[unitic.poly.f[i][1]][1], unitic.poly.v[unitic.poly.f[i][2]][1], unitic.poly.v[unitic.poly.f[i][3]][1] },
			y = { unitic.poly.v[unitic.poly.f[i][1]][2], unitic.poly.v[unitic.poly.f[i][2]][2], unitic.poly.v[unitic.poly.f[i][3]][2] }
		}

		--we discard those polygons that will not be visible
		local tri_face
		if unitic.poly.f[i].f~=0 and unitic.poly.f[i].f~=3 then
			tri_face = (p2d.x[2] - p2d.x[1]) * (p2d.y[3] - p2d.y[1]) - (p2d.x[3] - p2d.x[1]) * (p2d.y[2] - p2d.y[1]) < 0
		end

		if unitic.poly.f[i].f~=0
		and not (tri_face and unitic.poly.f[i].f==1)
		and not (not tri_face and unitic.poly.f[i].f==2)
		and not (unitic.poly.v[unitic.poly.f[i][1]][4] and unitic.poly.v[unitic.poly.f[i][2]][4] and unitic.poly.v[unitic.poly.f[i][3]][4])
		and not (p2d.x[1]<0 and p2d.x[2]<0 and p2d.x[3]<0)
		and not (p2d.y[1]<0 and p2d.y[2]<0 and p2d.y[3]<0)
		and not (p2d.x[1]>239 and p2d.x[2]>239 and p2d.x[3]>239)
		and not (p2d.y[1]>135 and p2d.y[2]>135 and p2d.y[3]>135)
		then
			ttri(
				p2d.x[1], p2d.y[1],
				p2d.x[2], p2d.y[2],
				p2d.x[3], p2d.y[3],
				unitic.poly.f[i].uv.x[1], unitic.poly.f[i].uv.y[1],
				unitic.poly.f[i].uv.x[2], unitic.poly.f[i].uv.y[2],
				unitic.poly.f[i].uv.x[3], unitic.poly.f[i].uv.y[3], 0, 15,
				unitic.poly.v[unitic.poly.f[i][1]][3],
				unitic.poly.v[unitic.poly.f[i][2]][3],
				unitic.poly.v[unitic.poly.f[i][3]][3])
		end
	end
	for i = 1, #unitic.poly.sp do
		local p2d = {}

		local x0 = unitic.poly.sp[i][1]
		local y0 = unitic.poly.sp[i][2]
		local z0 = unitic.poly.sp[i][3]

		p2d.x = unitic.fov * x0 / z0 + 120
		p2d.y = unitic.fov * y0 / z0 + 68

		if z0 < -1 then
			pix(p2d.x, p2d.y, 0)
			print(i, p2d.x, p2d.y, 7)
		end
	end
	if #unitic.p~=0 and st.p then
		for i = 1, #unitic.p do
			if unitic.p[i][4] then
				local p2d = {x=unitic.p[i][1],y=unitic.p[i][2]}

				local color = unitic.p[i][5]
				local color1= color % 4
				local color2= color //4

				local z0 = unitic.p[i][3]

				ttri(
					p2d.x  ,p2d.y,
					p2d.x  ,p2d.y+1,
					p2d.x+2,p2d.y,
					--uv
					24 + color1*2 ,248 + color2*2 ,
					24 + color1*2 ,249 + color2*2 ,
					25 + color1*2 ,248 + color2*2 ,

					0,-1,
					z0,z0,z0
				)
			end
		end
	end
end

local wall_coll={[1]=true,[2]=true,[3]=true,[4]=true,[8]=true,[9]=true,[10]=true,[13]=true,[14]=true,[16]=true,[17]=true,[18]=true}
function unitic.player_collision()
	local colx = false
	local coly = false
	local colz = false

	local x1=max((plr.x-17)//96,0)
	local y1=max((plr.y-65)//128,0)
	local z1=max((plr.z-17)//96,0)

	local x2=min((plr.x+16)//96,world_size[1]-1)
	local y2=min((plr.y+16)//128,world_size[2]-1)
	local z2=min((plr.z+16)//96,world_size[3]-1)

	for x0 = x1,x2 do for y0 = y1,y2 do for z0 = z1,z2 do
		if wall_coll[draw.map[1][x0][y0][z0][2]] then
			if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colx = true end
			if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then coly = true end
			if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colz = true end
		elseif draw.map[1][x0][y0][z0][2]==5 or draw.map[1][x0][y0][z0][2]==6 then
			if not draw.p[1] or not draw.p[2] then
				if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colx = true end
				if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then coly = true end
				if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colz = true end
			else
				if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 2)
				or coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 94, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
				or coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96, y0 * 128 + 126, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colx = true end

				if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 2)
				or coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 94, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
				or coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96, y0 * 128 + 126, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then coly = true end

				if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 2)
				or coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 94, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
				or coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96, y0 * 128 + 126, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colz = true end
			end
		elseif draw.map[1][x0][y0][z0][2]==7 then
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then plr.cd2=10 end
		elseif draw.map[1][x0][y0][z0][2]==15 then
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then plr.hp=0 sfx(2,"C-3",-1,1) end
		end

		if draw.map[2][x0][y0][z0][2] > 0 and draw.map[2][x0][y0][z0][2]~=5 and draw.map[2][x0][y0][z0][2]~=8 and draw.map[2][x0][y0][z0][2]~=9 then
			if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then colx = true end
			if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then coly = true end
			if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then colz = true end
		elseif draw.map[2][x0][y0][z0][2]==5 then
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then plr.hp=0 sfx(2,"C-3",-1,1) end
		elseif draw.map[2][x0][y0][z0][2]==8 or draw.map[2][x0][y0][z0][2]==9 then
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then plr.vy=12 sfx(0,"C-6",-1,1) end
		end

		if wall_coll[draw.map[3][x0][y0][z0][2]] then
			if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colx = true end
			if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then coly = true end
			if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colz = true end
		elseif draw.map[3][x0][y0][z0][2]==5 or draw.map[3][x0][y0][z0][2]==6 then
			if not draw.p[1] or not draw.p[2] then
				if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colx = true end
				if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then coly = true end
				if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colz = true end
			else
				if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96)
				or coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96 + 94, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
				or coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 126, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colx = true end

				if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96)
				or coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96 + 94, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
				or coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 126, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then coly = true end

				if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96)
				or coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96 + 94, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
				or coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96 + 2, y0 * 128 + 126, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colz = true end
			end
		elseif draw.map[3][x0][y0][z0][2]==7 then
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then plr.cd2=10 end
		elseif draw.map[3][x0][y0][z0][2]==15 then
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then plr.hp=0 sfx(2,"C-3",-1,1) end
		end
	end end end
	--collision with objects
	for i=1,#draw.objects.c do
		local x0=draw.objects.c[i].x
		local y0=draw.objects.c[i].y
		local z0=draw.objects.c[i].z
		if not coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then --protection so that the player cannot get stuck in the cube
			if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then colx = true end
			if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then coly = true end
			if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then colz = true end
		end
	end

	for i=1,#draw.objects.cd do
		local x0=draw.objects.cd[i].x
		local y0=draw.objects.cd[i].y
		local z0=draw.objects.cd[i].z
		if not coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then
			if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then colx = true end
			if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then coly = true end
			if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then colz = true end
		end
	end

	for i=1,#draw.objects.lb do
		local x0=draw.objects.lb[i].x
		local y0=draw.objects.lb[i].y
		local z0=draw.objects.lb[i].z
		if not coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 - 48, y0, z0 - 48, x0 + 48, y0, z0 + 48) then
			if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 - 48, y0, z0 - 48, x0 + 48, y0, z0 + 48) then colx = true end
			if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 - 48, y0, z0 - 48, x0 + 48, y0, z0 + 48) then coly = true end
			if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 - 48, y0, z0 - 48, x0 + 48, y0, z0 + 48) then colz = true end
		end
	end

	for i=1,#draw.objects.b do
		local x0=draw.objects.b[i].x
		local y0=draw.objects.b[i].y
		local z0=draw.objects.b[i].z
		if not coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6) then
			if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6) then colx = true end
			if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6) then coly = true end
			if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6) then colz = true end
		end
	end

	for i=1,#draw.objects.t do
		local x0=draw.objects.t[i].x
		local y0=draw.objects.t[i].y
		local z0=draw.objects.t[i].z
		if not coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16,       x0 - 12, y0, z0 - 12, x0 + 12, y0 + 69, z0 + 12) then
			if  coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 - 12, y0, z0 - 12, x0 + 12, y0 + 69, z0 + 12) then colx = true end
			if  coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 - 12, y0, z0 - 12, x0 + 12, y0 + 69, z0 + 12) then coly = true end
			if  coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 - 12, y0, z0 - 12, x0 + 12, y0 + 69, z0 + 12) then colz = true end
		end
	end

	if not plr.noclip then
		if colx then plr.x = lx end
		if coly then plr.y = ly end
		if colz then plr.z = lz end
		plr.xy=coly
	end
end

local function cube_interact(cube)
	if plr.holding and not cube.held then return false end

	local rc=raycast(
		plr.x,plr.y,plr.z,
		cube.x,cube.y,cube.z,
		{[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true,[10]=true,[13]=true,[14]=true,[15]=true,[16]=true,[17]=true,[18]=true,[19]=true},
		{[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true})

	local txsin = math.sin(plr.tx)
	local txcos = math.cos(plr.tx)
	local tysin = math.sin(-plr.ty)
	local tycos = math.cos(-plr.ty)

	local vx = tysin * txcos
	local vy = -txsin
	local vz = -tycos * txcos

	local dx = cube.x-plr.x
	local dy = cube.y-plr.y
	local dz = cube.z-plr.z

	local dist = (dx^2 + dy^2 + dz^2)^0.5
	local dot = dx * vx + dy * vy + dz * vz

	local cosang = dot / dist

	if cube.held then
		return keyp(5) or dist > 300 or rc
	else
		return keyp(5) and dist < 150 and not rc and cosang > 0.95
	end
end

function unitic.cube_update() --all physics related to cubes
	local holding = plr.holding
	local i=0 if #draw.objects.c~=0 then
		repeat
			i=i+1

			if cube_interact(draw.objects.c[i]) then
				draw.objects.c[i].held = not draw.objects.c[i].held
				holding = not plr.holding
			end

			local clx=draw.objects.c[i].x
			local cly=draw.objects.c[i].y
			local clz=draw.objects.c[i].z

			local cx=draw.objects.c[i].x
			local cy=draw.objects.c[i].y
			local cz=draw.objects.c[i].z

			if draw.objects.c[i].held then
				local hold_dist = 100
				local txsin = math.sin(plr.tx)
				local txcos = math.cos(plr.tx)
				local tysin = math.sin(-plr.ty)
				local tycos = math.cos(-plr.ty)
				local tx = plr.x + hold_dist * tysin * txcos
				local ty = plr.y + hold_dist * -txsin
				local tz = plr.z + hold_dist * -tycos * txcos
				local dx,dy,dz=tx-cx,ty-cy,tz-cz
				local dist = math.sqrt(dx^2 + dy^2 + dz^2)
				if dist ~= 0 then
					local mdist=min(20, dist)
					cx,cy,cz=cx+dx*(mdist/dist),cy+dy*(mdist/dist),cz+dz*(mdist/dist)
				end
			else
				cx=cx+draw.objects.c[i].vx
				cy=cy+draw.objects.c[i].vy
				cz=cz+draw.objects.c[i].vz
				draw.objects.c[i].vy=max(draw.objects.c[i].vy-0.5,-20)
			end

			local inbp = false --is the cube in the blue portal
			local inop = false --is the cube in the orange portal
			local bf   = false --is the cube in the blue field

			local x1=max((cx-25)//96,0) -- +-24
			local y1=max((cy-25)//128,0)
			local z1=max((cz-25)//96,0)

			local x2=min((cx+25)//96,world_size[1]-1)
			local y2=min((cy+25)//128,world_size[2]-1)
			local z2=min((cz+25)//96,world_size[3]-1)

			local function update_pos_vel(sx, sy, sz)
					cx, cy, cz = cx + sx, cy + sy, cz + sz
					if sx ~= 0 then draw.objects.c[i].vx = 0 end
					if sy ~= 0 then draw.objects.c[i].vy = 0 end
					if sz ~= 0 then draw.objects.c[i].vz = 0 end
			end

			local function collide(x3, y3, z3, x4, y4, z4)
				-- try moving the current amount in each axis, partially cancelling if needed
				local sx = coll_shift(
					cx - 24, cly - 24, clz - 24, cx + 24, cly + 24, clz + 24,
					x3, y3, z3, x4, y4, z4, 1
				)
				if sx ~= 0 then draw.objects.c[i].vx = 0 end
				cx = cx + sx
				local sy = coll_shift(
					clx - 24, cy - 24, clz - 24, clx + 24, cy + 24, clz + 24,
					x3, y3, z3, x4, y4, z4, 2
				)
				if sy ~= 0 then draw.objects.c[i].vy = 0 end
				cy = cy + sy
				local sz = coll_shift(
					clx - 24, cly - 24, cz - 24, clx + 24, cly + 24, cz + 24,
					x3, y3, z3, x4, y4, z4, 3
				)
				if sz ~= 0 then draw.objects.c[i].vz = 0 end
				cz = cz + sz
			end

			for x0 = x1,x2 do for y0 = y1,y2 do for z0 = z1,z2 do
				if wall_coll[draw.map[1][x0][y0][z0][2]] then
					collide(x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
				elseif draw.map[1][x0][y0][z0][2]==5 or draw.map[1][x0][y0][z0][2]==6 then
					if not draw.p[1] or not draw.p[2] then
						collide(x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
					else
						if draw.map[1][x0][y0][z0][2]==5 and coll( clx - 24, cly - 24, clz - 24,  clx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then inbp=true end
						if draw.map[1][x0][y0][z0][2]==6 and coll( clx - 24, cly - 24, clz - 24,  clx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then inop=true end

						collide(x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 2)
						collide(x0 * 96, y0 * 128 + 2, z0 * 96 + 94, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
						collide(x0 * 96, y0 * 128 + 126, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
					end
				elseif draw.map[1][x0][y0][z0][2]==7 then
					if coll(clx - 24,  cly - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then bf = true end
				end

				if draw.map[2][x0][y0][z0][2] > 0 and draw.map[2][x0][y0][z0][2]~=5 and draw.map[2][x0][y0][z0][2]~=8 and draw.map[2][x0][y0][z0][2]~=9 then
					collide(x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94)
				elseif draw.map[2][x0][y0][z0][2]==8 or draw.map[2][x0][y0][z0][2]==9 then
					if coll(clx - 24, cly - 24, clz - 24, clx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then draw.objects.c[i].vy=12 sfx(0,"C-6",-1,1) end
				end

				if wall_coll[draw.map[3][x0][y0][z0][2]] then
					collide(x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
				elseif draw.map[3][x0][y0][z0][2]==5 or draw.map[3][x0][y0][z0][2]==6 then
					if not draw.p[1] or not draw.p[2] then
						collide(x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
					else
						if draw.map[3][x0][y0][z0][2]==5 and coll( clx - 24, cly - 24, clz - 24,  clx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96) then inbp=true end
						if draw.map[3][x0][y0][z0][2]==6 and coll( clx - 24, cly - 24, clz - 24,  clx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96) then inop=true end

						collide(x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96)
						collide(x0 * 96 + 94, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
						collide(x0 * 96 + 2, y0 * 128 + 126, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
					end
				elseif draw.map[3][x0][y0][z0][2]==7 then
					if coll(clx - 24, cly - 24, clz - 24, clx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then bf=true end
				end

			end end end
			--collision with the player
			do
				local x0=plr.x
				local y0=plr.y
				local z0=plr.z
				collide(x0 - 16, y0 - 64, z0 - 16, x0 + 16, y0 + 16, z0 + 16)
			end

			--collision with objects
			for i2=1,#draw.objects.c do
				if i2~=i then
					local x0=draw.objects.c[i2].x
					local y0=draw.objects.c[i2].y
					local z0=draw.objects.c[i2].z
					collide(x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24)
				end
			end

			for i2=1,#draw.objects.lb do
				local x0=draw.objects.lb[i2].x
				local y0=draw.objects.lb[i2].y
				local z0=draw.objects.lb[i2].z
				collide(x0 - 48, y0 + 5, z0 - 48, x0 + 48, y0 + 5, z0 + 48)
			end

			for i2=1,#draw.objects.b do
				local x0=draw.objects.b[i2].x
				local y0=draw.objects.b[i2].y
				local z0=draw.objects.b[i2].z
				collide(x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6)
			end

			--
			draw.objects.c[i].x = cx
			draw.objects.c[i].y = cy
			draw.objects.c[i].z = cz

			if bf then
				--particles
				for i2=1,20 do
					addp(cx-24       ,cy+R(-24,24),cz+R(-24,24),R()*2-1,R()*2-1,R()*2-1,R(30,60),1)
					addp(cx+24       ,cy+R(-24,24),cz+R(-24,24),R()*2-1,R()*2-1,R()*2-1,R(30,60),1)
					addp(cx+R(-24,24),cy-24       ,cz+R(-24,24),R()*2-1,R()*2-1,R()*2-1,R(30,60),1)
					addp(cx+R(-24,24),cy+24       ,cz+R(-24,24),R()*2-1,R()*2-1,R()*2-1,R(30,60),1)
					addp(cx+R(-24,24),cy+R(-24,24),cz-24       ,R()*2-1,R()*2-1,R()*2-1,R(30,60),1)
					addp(cx+R(-24,24),cy+R(-24,24),cz+24       ,R()*2-1,R()*2-1,R()*2-1,R(30,60),1)
				end
				--
				table.remove(draw.objects.c,i)
				i=i-1
			end
		until i>=#draw.objects.c
	end
	plr.holding = holding
end

local function portalcenter(i)
	local x, y, z = table.unpack(draw.p[i])
	if draw.p[i][4] == 3 then
		x = x + 0.5
	else
		z = z + 0.5
	end
	y = y + 0.5
	return x, y, z
end

function unitic.portal_collision()
	if not draw.p[1] or not draw.p[2] then return end
	local bp=false --does the code need to teleport the player out of the blue portal
	local op=false	--does the code need to teleport the player out of the orange portal
	--Blue portal
	if draw.p[1][4]==1 and draw.p[1][5]==1 and coll(plr.x - 16, plr.y - 64, plr.z - 16, plr.x, plr.y + 16, plr.z + 16, draw.p[1][1] * 96, draw.p[1][2] * 128 + 2, draw.p[1][3] * 96 + 2, draw.p[1][1] * 96, draw.p[1][2] * 128 + 126, draw.p[1][3] * 96 + 94) then bp=true end
	if draw.p[1][4]==3 and draw.p[1][5]==1 and coll(plr.x - 16, plr.y - 64, plr.z, plr.x + 16, plr.y + 16, plr.z + 16, draw.p[1][1] * 96 + 2, draw.p[1][2] * 128 + 2, draw.p[1][3] * 96, draw.p[1][1] * 96 + 94, draw.p[1][2] * 128 + 126, draw.p[1][3] * 96) then bp=true end
	if draw.p[1][4]==1 and draw.p[1][5]==2 and coll(plr.x, plr.y - 64, plr.z - 16, plr.x + 16, plr.y + 16, plr.z + 16, draw.p[1][1] * 96, draw.p[1][2] * 128 + 2, draw.p[1][3] * 96 + 2, draw.p[1][1] * 96, draw.p[1][2] * 128 + 126, draw.p[1][3] * 96 + 94) then bp=true end
	if draw.p[1][4]==3 and draw.p[1][5]==2 and coll(plr.x - 16, plr.y - 64, plr.z - 16, plr.x + 16, plr.y + 16, plr.z, draw.p[1][1] * 96 + 2, draw.p[1][2] * 128 + 2, draw.p[1][3] * 96, draw.p[1][1] * 96 + 94, draw.p[1][2] * 128 + 126, draw.p[1][3] * 96) then bp=true end
	--orange portal
	if draw.p[2][4]==1 and draw.p[2][5]==1 and coll(plr.x - 16, plr.y - 64, plr.z - 16, plr.x, plr.y + 16, plr.z + 16, draw.p[2][1] * 96, draw.p[2][2] * 128 + 2, draw.p[2][3] * 96 + 2, draw.p[2][1] * 96, draw.p[2][2] * 128 + 126, draw.p[2][3] * 96 + 94) then op=true end
	if draw.p[2][4]==3 and draw.p[2][5]==1 and coll(plr.x - 16, plr.y - 64, plr.z, plr.x + 16, plr.y + 16, plr.z + 16, draw.p[2][1] * 96 + 2, draw.p[2][2] * 128 + 2, draw.p[2][3] * 96, draw.p[2][1] * 96 + 94, draw.p[2][2] * 128 + 126, draw.p[2][3] * 96) then op=true end
	if draw.p[2][4]==1 and draw.p[2][5]==2 and coll(plr.x, plr.y - 64, plr.z - 16, plr.x + 16, plr.y + 16, plr.z + 16, draw.p[2][1] * 96, draw.p[2][2] * 128 + 2, draw.p[2][3] * 96 + 2, draw.p[2][1] * 96, draw.p[2][2] * 128 + 126, draw.p[2][3] * 96 + 94) then op=true end
	if draw.p[2][4]==3 and draw.p[2][5]==2 and coll(plr.x - 16, plr.y - 64, plr.z - 16, plr.x + 16, plr.y + 16, plr.z, draw.p[2][1] * 96 + 2, draw.p[2][2] * 128 + 2, draw.p[2][3] * 96, draw.p[2][1] * 96 + 94, draw.p[2][2] * 128 + 126, draw.p[2][3] * 96) then op=true end
	--teleporting

	local x1, y1, z1 = portalcenter(1)
	local x2, y2, z2 = portalcenter(2)

	-- calculate portal offsets
	local relx1 = plr.x - 96 * x1
	local rely1 = plr.y - 128 * y1
	local relz1 = plr.z - 96 * z1
	local relx2 = plr.x - 96 * x2
	local rely2 = plr.y - 128 * y2
	local relz2 = plr.z - 96 * z2

	-- calculate portal rotation
	local rot1 = draw.p[1][4] // 2 + (draw.p[1][5] - 1) * 2
	local rot2 = draw.p[2][4] // 2 + (draw.p[2][5] - 1) * 2
	local rotd1 = (2 + rot2 - rot1) % 4
	local rotd2 = (2 + rot1 - rot2) % 4

	if     rotd1 == 0 then
	elseif rotd1 == 1 then relx1,relz1=relz1,-relx1
	elseif rotd1 == 2 then relx1,relz1=-relx1,-relz1
	elseif rotd1 == 3 then relx1,relz1=-relz1,relx1
  	end

	if     rotd2 == 0 then
	elseif rotd2 == 1 then relx2,relz2=relz2,-relx2
	elseif rotd2 == 2 then relx2,relz2=-relx2,-relz2
	elseif rotd2 == 3 then relx2,relz2=-relz2,relx2
  	end


	if bp and op==false then
		plr.x = 96*x2 + relx1
		plr.y = 128*y2 + rely1
		plr.z = 96*z2 + relz1
		plr.ty = plr.ty + math.pi * rotd1 / 2
		plr.tx = plr.tx
	elseif op and bp==false then
		plr.x = 96*x1 + relx2
		plr.y = 128*y1 + rely2
		plr.z = 96*z1 + relz2
		plr.ty = plr.ty + math.pi * rotd2 / 2
		plr.tx = plr.tx
	end
end

function unitic.render() --------
	--dynamic textures
	if st.d_t then
		for x0=0,15 do --light bridge
			for y0=0,11 do setpix(x0,y0+234,15) end
			local y0=(math.sin((-t%30+x0*2)/5)+1)*6
			local y1=(math.cos((-t%30+x0*2)/5)+1)*6
			local y2=(math.sin(t/20)+1)*6
			setpix(x0,F(y0)+234,11)
			setpix(x0,F(y1)+234,10)
			setpix(x0,F(y2)+234,11)
		end
		--blue / red field
		for y0=0,31,2 do
			if b_f[y0].d then
				setpix((b_f[y0][1]+t//2)%24+24,y0+32,b_f[y0][3])
				setpix((b_f[y0][2]+t//2)%24+24,y0+32,15)
				--red field
				setpix((b_f[y0][1]+t//2)%24+96,y0+64,b_f[y0][3]-2)
				setpix((b_f[y0][2]+t//2)%24+96,y0+64,15)

				setpix((b_f[y0][1]+t//2)%24+96,y0+152,b_f[y0][3]-2)
				setpix((b_f[y0][2]+t//2)%24+96,y0+152,15)
			end
			if b_f[y0+1].d then
				setpix((b_f[y0+1][1]+t//2*23)%24+24,y0+33,15)
				setpix((b_f[y0+1][2]+t//2*23)%24+24,y0+33,b_f[y0+1][3])
				--red field
				setpix((b_f[y0+1][1]+t//2*23)%24+96,y0+65,15)
				setpix((b_f[y0+1][2]+t//2*23)%24+96,y0+65,b_f[y0+1][3]-2)

				setpix((b_f[y0+1][1]+t//2*23)%24+96,y0+153,15)
				setpix((b_f[y0+1][2]+t//2*23)%24+96,y0+153,b_f[y0+1][3]-2)
			end
		end
	end
	--particles
	for i=1,#draw.pr_g do
		local  x=draw.pr_g[i][1]*96
		local  y=draw.pr_g[i][2]*128+4
		local  z=draw.pr_g[i][3]*96
		local vx=draw.pr_g[i][4]
		local vz=draw.pr_g[i][5]
		for i=0,15 do
			if vx~=0 then
				addp(x,y,z+i*96/16,-vx*R(1,4),R(-2,2),R(-2,2),R(2,10),R(10,11))
			else
				addp(x+i*96/16,y,z,R(-2,2),R(-2,2),-vz*R(1,4),R(2,10),R(10,11))
			end
		end
	end
	--
	local dist1, dist2, dist = math.huge, math.huge, false

	local txsin = math.sin( plr.tx)
	local txcos = math.cos( plr.tx)
	local tysin = math.sin(-plr.ty)
	local tycos = math.cos(-plr.ty)
	if draw.p[1] then
		local x1, y1, z1 = portalcenter(1)

		local a1 = x1*96  - plr.x
		local b1 = y1*128 - plr.y
		local c1 = z1*96  - plr.z

		local c2 = c1 * tycos - a1 * tysin

		local a3 = c1 * tysin + a1 * tycos
		local b3 = b1 * txcos - c2 * txsin
		local c3 = b1 * txsin + c2 * txcos

		if c3>-0.001 then c3=-0.001 end
		local z0 = unitic.fov / c3

		local x0 = a3 * z0
		local y0 = b3 * z0

		dist1=(x0^2 + y0^2)^0.5
	end

	if draw.p[2] then
		local x2, y2, z2 = portalcenter(2)

		local a1 = x2*96  - plr.x
		local b1 = y2*128 - plr.y
		local c1 = z2*96  - plr.z

		local c2 = c1 * tycos - a1 * tysin

		local a3 = c1 * tysin + a1 * tycos
		local b3 = b1 * txcos - c2 * txsin
		local c3 = b1 * txsin + c2 * txcos

		if c3>-0.001 then c3=-0.001 end
		local z0 = unitic.fov / c3

		local x0 = a3 * z0
		local y0 = b3 * z0

		dist2=(x0^2 + y0^2)^0.5
		dist = true
	end

	if draw.p[1] and draw.p[2] then
		dist=dist1 < dist2
	end

	vbank(0)
	cls()
	fps_.t4=time()
	fps_.t5=fps_.t4
	fps_.t6=fps_.t4

	if st.r_p and draw.p[1] and draw.p[2] then
		local x1, y1, z1 = portalcenter(1)
		local x2, y2, z2 = portalcenter(2)

		-- calculate portal offsets
		local relx1 = plr.x - 96 * x1
		local rely1 = plr.y - 128 * y1
		local relz1 = plr.z - 96 * z1
		local relx2 = plr.x - 96 * x2
		local rely2 = plr.y - 128 * y2
		local relz2 = plr.z - 96 * z2

		-- calculate portal rotation
		local rot1 = draw.p[1][4] // 2 + (draw.p[1][5] - 1) * 2
		local rot2 = draw.p[2][4] // 2 + (draw.p[2][5] - 1) * 2
		local rotd1 = (2 + rot2 - rot1) % 4
		local rotd2 = (2 + rot1 - rot2) % 4

		if     rotd1 == 0 then
		elseif rotd1 == 1 then relx1,relz1=relz1,-relx1
		elseif rotd1 == 2 then relx1,relz1=-relx1,-relz1
		elseif rotd1 == 3 then relx1,relz1=-relz1,relx1
		end

		if     rotd2 == 0 then
		elseif rotd2 == 1 then relx2,relz2=relz2,-relx2
		elseif rotd2 == 2 then relx2,relz2=-relx2,-relz2
		elseif rotd2 == 3 then relx2,relz2=-relz2,relx2
		end
		fps_.t4=time()
		if st.h_q_p or min(dist1,dist2)<128^2 or (t%2==0 and min(dist1,dist2)<512^2) or (t%3==0 and min(dist1,dist2)>=512^2) then
				if dist then
					cam.x = 96*x2 + relx1
					cam.y = 128*y2 + rely1
					cam.z = 96*z2 + relz1
					cam.ty = plr.ty + math.pi * rotd1 / 2
					cam.tx = plr.tx
					unitic.update(true,1) unitic.draw() --blue portal
				else
					cam.x = 96*x1 + relx2
					cam.y = 128*y1 + rely2
					cam.z = 96*z1 + relz2
					cam.ty = plr.ty + math.pi * rotd2 / 2
					cam.tx = plr.tx
					unitic.update(true,2) unitic.draw() --orange portal
				end
				fps_.t5=time()

				if st.r_both and draw.p[1] and draw.p[2] then
					vbank(1) do
						cls(0)
						local p_verts = dist and draw.p_verts[1] or draw.p_verts[2]
						local portal = {draw.world.v[p_verts[1][1]], draw.world.v[p_verts[1][2]], draw.world.v[p_verts[1][3]], draw.world.v[p_verts[2][2]]}

						local txsin = math.sin(plr.tx)
						local txcos = math.cos(plr.tx)
						local tysin = math.sin(-plr.ty)
						local tycos = math.cos(-plr.ty)
						for ind = 1, 4 do
							local a1 = portal[ind][1] - plr.x
							local b1 = portal[ind][2] - plr.y
							local c1 = portal[ind][3] - plr.z

							local c2 = c1 * tycos - a1 * tysin

							local a3 = c1 * tysin + a1 * tycos
							local b3 = b1 * txcos - c2 * txsin
							local c3 = b1 * txsin + c2 * txcos
							local c4 = c3
							if c4>-0.001 then c4=-0.001 end
							local z0 = unitic.fov / c4

							local x0 = a3 * z0 + 120
							local y0 = b3 * z0 + 68

							portal[ind] = {x0, y0, -c4, c3 > 0}
						end
						local mz1, mz2, mz3, mz4 = portal[1][3], portal[2][3], portal[3][3], portal[4][3]
						local minz = min(mz1, mz2, mz3, mz4)
						if minz > 1e-10 then
							local div = minz/1e-10
							mz1,mz2,mz3,mz4=mz1/div,mz2/div,mz3/div,mz4/div
						end
						if not (portal[1][4] and portal[2][4] and portal[3][4] and portal[4][4]) then
							ttri(
								portal[1][1],portal[1][2],
								portal[2][1],portal[2][2],
								portal[3][1],portal[3][2],
								24,232,
								0,232,
								24,200,
								0,15,
								mz1,
								mz2,
								mz3
							)
							ttri(
								portal[2][1],portal[2][2],
								portal[4][1],portal[4][2],
								portal[3][1],portal[3][2],
								0,232,
								0,200,
								24,200,
								0,15,
								mz2,
								mz4,
								mz3
							)
						end
					end vbank(0)
					if dist then
						cam.x = 96*x1 + relx2
						cam.y = 128*y1 + rely2
						cam.z = 96*z1 + relz2
						cam.ty = plr.ty + math.pi * rotd2 / 2
						cam.tx = plr.tx
						unitic.update(true,2) unitic.draw() --orange portal
					else
						cam.x = 96*x2 + relx1
						cam.y = 128*y2 + rely1
						cam.z = 96*z2 + relz1
						cam.ty = plr.ty + math.pi * rotd1 / 2
						cam.tx = plr.tx
						unitic.update(true,1) unitic.draw() --blue portal
					end
				end
				memcpy(0x8000,0x0,240*136/2)
				fps_.t6=time()
				
			else
				memcpy(0x0,0x8000,240*136/2)
			end
	end

	vbank(1)
	if not st.potato_pc or R()<0.05 then cls(1) end
	cam.x, cam.y, cam.z, cam.tx, cam.ty = plr.x, plr.y, plr.z, plr.tx, plr.ty
	unitic.update_pr()
	unitic.update()
	fps_.t7=time()
	unitic.draw()
	fps_.t8=time()
	if (draw.p[1] or draw.p[2]) and not (st.r_both and draw.p[1] and draw.p[2]) then
		--portal overlays
		local v_id={}
		if dist then
			v_id={
				draw.p[2][1]+draw.p[2][2]*world_size[3]+draw.p[2][3]*world_size[4]+1,
				draw.p[2][1]+draw.p[2][2]*world_size[3]+draw.p[2][3]*world_size[4]+world_size[3]+1}
			if draw.p[2][4]==1 then
				v_id[3]=draw.p[2][1]+draw.p[2][2]*world_size[3]+draw.p[2][3]*world_size[4]+world_size[4]+1
				v_id[4]=draw.p[2][1]+draw.p[2][2]*world_size[3]+draw.p[2][3]*world_size[4]+world_size[4]+world_size[3]+1
			else
				v_id[3]=draw.p[2][1]+draw.p[2][2]*world_size[3]+draw.p[2][3]*world_size[4]+2
				v_id[4]=draw.p[2][1]+draw.p[2][2]*world_size[3]+draw.p[2][3]*world_size[4]+world_size[3]+2
			end
		else
			v_id={
				draw.p[1][1]+draw.p[1][2]*world_size[3]+draw.p[1][3]*world_size[4]+1,
				draw.p[1][1]+draw.p[1][2]*world_size[3]+draw.p[1][3]*world_size[4]+world_size[3]+1}
			if draw.p[1][4]==1 then
				v_id[3]=draw.p[1][1]+draw.p[1][2]*world_size[3]+draw.p[1][3]*world_size[4]+world_size[4]+1
				v_id[4]=draw.p[1][1]+draw.p[1][2]*world_size[3]+draw.p[1][3]*world_size[4]+world_size[4]+world_size[3]+1
			else
				v_id[3]=draw.p[1][1]+draw.p[1][2]*world_size[3]+draw.p[1][3]*world_size[4]+2
				v_id[4]=draw.p[1][1]+draw.p[1][2]*world_size[3]+draw.p[1][3]*world_size[4]+world_size[3]+2
			end
		end

		local p2d={x={},y={},z={},z2={}}
		for i=1,4 do
			p2d.x[i]=unitic.poly.v[v_id[i]][1]
			p2d.y[i]=unitic.poly.v[v_id[i]][2]
			p2d.z[i]=unitic.poly.v[v_id[i]][3]
			p2d.z2[i]=unitic.poly.v[v_id[i]][4]
		end

		local tri_face = (p2d.x[2] - p2d.x[1]) * (p2d.y[3] - p2d.y[1]) - (p2d.x[3] - p2d.x[1]) * (p2d.y[2] - p2d.y[1]) < 0

		if dist and ((tri_face and draw.p[2][5]==1) or (tri_face==false and draw.p[2][5]==2)) and (p2d.z2[1] and p2d.z2[2] and p2d.z2[3] and p2d.z2[4])==false then
			ttri(p2d.x[1],p2d.y[1],p2d.x[2],p2d.y[2],p2d.x[3],p2d.y[3],48,232,48,200,24,232,0,15,p2d.z[1]*0.99,p2d.z[2]*0.99,p2d.z[3]*0.99) --orange
			ttri(p2d.x[4],p2d.y[4],p2d.x[2],p2d.y[2],p2d.x[3],p2d.y[3],24,200,48,200,24,232,0,15,p2d.z[4]*0.99,p2d.z[2]*0.99,p2d.z[3]*0.99)
		elseif dist==false and ((tri_face and draw.p[1][5]==1) or (tri_face==false and draw.p[1][5]==2)) and (p2d.z2[1] and p2d.z2[2] and p2d.z2[3] and p2d.z2[4])==false then
			ttri(p2d.x[1],p2d.y[1],p2d.x[2],p2d.y[2],p2d.x[3],p2d.y[3],24,232,24,200,0,232,0,15,p2d.z[1]*0.99,p2d.z[2]*0.99,p2d.z[3]*0.99)
			ttri(p2d.x[4],p2d.y[4],p2d.x[2],p2d.y[2],p2d.x[3],p2d.y[3],0 ,200,24,200,0,232,0,15,p2d.z[4]*0.99,p2d.z[2]*0.99,p2d.z[3]*0.99)
		end
	end

	--cross
	pix(120,68,4)
	if true then pix(120,68,7) end
	if draw.p[1] or draw.p[2] then spr(498,117,65,1) end
	if draw.p[1] then spr(496, 117, 65, 1) end
	if draw.p[2] then spr(497, 117, 65, 1) end
	fps_.t9=time()
end

function unitic.turret_update()
	for i=1,#draw.objects.t do
		local t_ang=0
		if     draw.objects.t[i].type==12 then t_ang=pi2
		elseif draw.objects.t[i].type==13 then t_ang=-pi2
		elseif draw.objects.t[i].type==14 then t_ang=0
		elseif draw.objects.t[i].type==15 then t_ang=-math.pi end

		local x0=draw.objects.t[i].x
		local y0=draw.objects.t[i].y
		local z0=draw.objects.t[i].z
		local ang=math.atan(x0-plr.x,z0-plr.z)-t_ang

		if abs(ang)<pi2*0.7 or abs(ang-(math.pi*2))<pi2*0.7 then
			local x=raycast(x0,y0+35,z0,plr.x,plr.y,plr.z,{[1]=true,[2]=true,[4]=true,[5]=true,[6]=true,[8]=true,[9]=true,[10]=true,[13]=true,[14]=true,[16]=true,[17]=true,[18]=true,[19]=true},{[1]=true,[2]=true,[4]=true,[6]=true,[7]=true,[8]=true,[9]=true})
			if not x then draw.objects.t[i].cd=min(draw.objects.t[i].cd+1,41)
				if draw.objects.t[i].cd>40 then
					plr.hp=plr.hp-R(1,2)
					if plr.cd3<2 then plr.cd3=5 sfx(4,"C-3",-1,1) end
					if draw.objects.t[i].type==14 or draw.objects.t[i].type==15 then
						for _=1,2 do
							addp(x0+16,y0+32,z0,R()-0.5,R()-0.5,R()-0.5,10,13+R(0,1))
							addp(x0+16,y0+48,z0,R()-0.5,R()-0.5,R()-0.5,10,13+R(0,1))
							addp(x0-16,y0+32,z0,R()-0.5,R()-0.5,R()-0.5,10,13+R(0,1))
							addp(x0-16,y0+48,z0,R()-0.5,R()-0.5,R()-0.5,10,13+R(0,1))
						end
					else
						for _=1,2 do
							addp(x0,y0+32,z0+16,R()-0.5,R()-0.5,R()-0.5,10,13+R(0,1))
							addp(x0,y0+48,z0+16,R()-0.5,R()-0.5,R()-0.5,10,13+R(0,1))
							addp(x0,y0+32,z0-16,R()-0.5,R()-0.5,R()-0.5,10,13+R(0,1))
							addp(x0,y0+48,z0-16,R()-0.5,R()-0.5,R()-0.5,10,13+R(0,1))
						end
					end
				end
			else
				draw.objects.t[i].cd=max(draw.objects.t[i].cd-1,0)
			end
		else
			draw.objects.t[i].cd=max(draw.objects.t[i].cd-1,0)
		end
	end
end

function unitic.button_update()
	--local f1={{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},{3 ,8 ,4 ,uv={{128,128},{125,132},{128,132},-1},f=2},{7 ,6 ,8 ,uv={{128,128},{125,132},{128,132},-1},f=2},{1 ,4 ,2 ,uv={{125,132},{128,128},{125,128},-1},f=2},{6 ,1 ,2 ,uv={{128,132},{125,128},{125,132},-1},f=2},{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},{3 ,7 ,8 ,uv={{128,128},{125,128},{125,132},-1},f=2},{7 ,5 ,6 ,uv={{128,128},{125,128},{125,132},-1},f=2},{1 ,3 ,4 ,uv={{125,132},{128,132},{128,128},-1},f=2},{6 ,5 ,1 ,uv={{128,132},{128,128},{125,128},-1},f=2},{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},}
	--local f2={{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},{3 ,8 ,4 ,uv={{128,132},{125,136},{128,136},-1},f=2},{7 ,6 ,8 ,uv={{128,132},{125,136},{128,136},-1},f=2},{1 ,4 ,2 ,uv={{125,136},{128,132},{125,132},-1},f=2},{6 ,1 ,2 ,uv={{128,136},{125,132},{125,136},-1},f=2},{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},{3 ,7 ,8 ,uv={{128,132},{125,132},{125,136},-1},f=2},{7 ,5 ,6 ,uv={{128,132},{125,132},{125,136},-1},f=2},{1 ,3 ,4 ,uv={{125,136},{128,136},{128,132},-1},f=2},{6 ,5 ,1 ,uv={{128,136},{128,132},{125,132},-1},f=2},{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},}
	for i=1,#draw.objects.b do
		draw.objects.b[i].tick=false
		if draw.objects.b[i].t~=-1 and draw.objects.b[i].s then
			draw.objects.b[i].t1=draw.objects.b[i].t1+1
			if draw.objects.b[i].t~=math.huge and draw.objects.b[i].t1>=draw.objects.b[i].t then
				if draw.objects.b[i].t~=0 then sfx(17) end draw.objects.b[i].s=false draw.objects.b[i].t1=0 draw.objects.b[i].tick=true
			end
		end

		local dist=((draw.objects.b[i].x-plr.x)^2 + (draw.objects.b[i].y-plr.y)^2 + (draw.objects.b[i].z-plr.z)^2) ^ 0.5
		local rc=raycast(
			draw.objects.b[i].x,draw.objects.b[i].y+26,draw.objects.b[i].z,
			plr.x,plr.y,plr.z,
			{[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true,[10]=true,[13]=true,[14]=true,[15]=true,[16]=true,[17]=true,[18]=true,[19]=true},
			{[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true})

		local ang=math.atan(draw.objects.b[i].x-plr.x,draw.objects.b[i].z-plr.z)-plr.ty

		if keyp(5) and dist<128 and not rc and ang<-2.5 and ang>-3.8 then
			sfx(16)
			draw.objects.b[i].tick=true
			if draw.objects.b[i].t==-1 then
				draw.objects.b[i].s=not draw.objects.b[i].s if not draw.objects.b[i].s then sfx(17)end
			else
				draw.objects.b[i].s=true draw.objects.b[i].t1=0
			end
		end
	end
end

local function portal_gun()
	local x1,y1,z1=plr.x,plr.y,plr.z --player coordinates

	local x2=x1-math.sin(plr.ty)*10000*math.cos(plr.tx)
	local y2=y1-math.sin(plr.tx)*10000
	local z2=z1-math.cos(plr.ty)*10000*math.cos(plr.tx)

	local x,y,z,f=raycast(x1,y1,z1,x2,y2,z2,{[1]=true,[2]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true,[10]=true,[13]=true,[14]=true,[16]=true,[17]=true,[18]=true,[19]=true},{[1]=true,[2]=true,[4]=true,[6]=true,[7]=true,[8]=true,[9]=true})

	if x and f~=2 and draw.map[f][x][y][z][2]==2 then
		if clp1 then
			if draw.p[1] then addwall(draw.p[1][1],draw.p[1][2],draw.p[1][3],draw.p[1][4],draw.p[1][5],2) end
			draw.p[1]={x,y,z,f,draw.map[f][x][y][z][1]}
			addwall(draw.p[1][1],draw.p[1][2],draw.p[1][3],draw.p[1][4],draw.p[1][5],5)
			update_world()
		elseif clp2 then
			if draw.p[2] then addwall(draw.p[2][1],draw.p[2][2],draw.p[2][3],draw.p[2][4],draw.p[2][5],2) end
			draw.p[2]={x,y,z,f,draw.map[f][x][y][z][1]}
			addwall(draw.p[2][1],draw.p[2][2],draw.p[2][3],draw.p[2][4],draw.p[2][5],6)
			update_world()
		end
	elseif x and (clp1 or clp2) then
		local x1,y1,z1=raycast(x1,y1,z1,x2,y2,z2,{[1]=true,[2]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true,[10]=true,[13]=true,[14]=true,[16]=true,[17]=true,[18]=true,[19]=true},{[1]=true,[2]=true,[4]=true,[6]=true,[7]=true,[8]=true,[9]=true},true)
		if clp1 then
			for i=0,99 do addp(x1,y1,z1,(R()-0.5)*5,(R()-0.5)*5,(R()-0.5)*5,R(5,25),R(10,11)) end
		elseif clp2 then
			for i=0,99 do addp(x1,y1,z1,(R()-0.5)*5,(R()-0.5)*5,(R()-0.5)*5,R(5,25),R(13,14)) end
		end
	end

	if keyp(6) or plr.cd2>1 then
		if draw.p[1] then addwall(draw.p[1][1],draw.p[1][2],draw.p[1][3],draw.p[1][4],draw.p[1][5],2) draw.p[1]=nil update_world() end
		if draw.p[2] then addwall(draw.p[2][1],draw.p[2][2],draw.p[2][3],draw.p[2][4],draw.p[2][5],2) draw.p[2]=nil update_world() end
	end
end

--map
function addwall(x, y, z, angle, face, type)
	draw.map[angle][x][y][z]={face,type}
end

function addobj(x, y, z, type,t1) --objects
	if type==1 or type==2 then --cubes
		draw.objects.c[#draw.objects.c+1]=
		{type=type, --type
		x=x,y=y,z=z, --object coordinates
		vy=0, --velocity
		draw=true, --whether to display the model
		model=model[type]}
	elseif type==3 then --cube dispenser
		draw.objects.cd[#draw.objects.cd+1]=
		{type=type,
		x=x,y=y,z=z,
		draw=true,
		model=model[type]}
	elseif type==4 or type==5 or type==6 or type==7 then --light bridges
		draw.objects.lb[#draw.objects.lb+1]=
		{type=type,
		x=x,y=y,z=z,
		draw=true,
		model=model[type]}
	elseif type==8 or type==9 or type==10 or type==11 then --buttons
		draw.objects.b[#draw.objects.b+1]=
		{type=type,
		x=x,y=y,z=z,
		t=t1 or (math.huge), --button press time (math.huge for a constant signal, -1 to switch the signal)
		t1=0,
		tick=false, --sends a signal 1 tick long while pressing the button
		s=false, --button signal
		draw=true,model={v=model[type].v,f=model[type].f}}
	elseif type==12 or type==13 or type==14 or type==15 then --turrets
		draw.objects.t[#draw.objects.t+1]=
		{type=type,
		x=x,y=y,z=z,
		cd=0,
		draw=true,model=model[type]}
	elseif type<=#model and type>0 then error("unknown object | "..type) else error("unknown type | "..type) end
end

function update_world()
	draw.world.f={}
	draw.world_bp.f={}
	draw.world_op.f={}
	draw.pr_g={}

	for angle=1,3 do for x0=0,world_size[1]-1 do for y0=0,world_size[2]-1 do for z0=0,world_size[3]-1 do
		local face = draw.map[angle][x0][y0][z0][1]
		local type = draw.map[angle][x0][y0][z0][2]-1

		local type1 = type%5
		local type2 = type//5
		------
		if type~=-1 then
			if angle==1 then
				table.insert(draw.world.f,{w={face,angle,x0,y0,z0},x0+y0*world_size[3]+z0*world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+1,f=face,uv={x={24+type1*24,type1*24,24+type1*24},y={32+type2*32,32+type2*32,0+type2*32}}})
				table.insert(draw.world.f,{w={face,angle,x0,y0,z0},x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+world_size[3]+1,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+1,f=face,uv={x={type1*24,type1*24,24+type1*24},y={32+type2*32,0+type2*32,0+type2*32}}})
			end

			if angle==2 then
				table.insert(draw.world.f,{w={face,angle,x0,y0,z0},x0+y0*world_size[3]+z0*world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+1,f=face,uv={x={0+type1*24,0+type1*24,24+type1*24},y={152+type2*24,176+type2*24,152+type2*24}}})
				table.insert(draw.world.f,{w={face,angle,x0,y0,z0},x0+y0*world_size[3]+z0*world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+1,f=face,uv={x={0+type1*24,24+type1*24,24+type1*24},y={176+type2*24,176+type2*24,152+type2*24}}})
			end

			if angle==3 then
				table.insert(draw.world.f,{w={face,angle,x0,y0,z0},x0+y0*world_size[3]+z0*world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+1,f=face,uv={x={24+type1*24,type1*24,24+type1*24},y={32+type2*32,32+type2*32,0+type2*32}}})
				table.insert(draw.world.f,{w={face,angle,x0,y0,z0},x0+y0*world_size[3]+z0*world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+1,f=face,uv={x={type1*24,type1*24,24+type1*24},y={32+type2*32,0+type2*32,0+type2*32}}})
			end


			if face == 2 and (angle == 1 or angle == 3) then
				local idx = #draw.world.f
				for i = 1, 3 do
					draw.world.f[idx - 1].uv.x[i] = (2 * type1 + 1) * 24 - draw.world.f[idx - 1].uv.x[i]
					draw.world.f[idx].uv.x[i] = (2 * type1 + 1) * 24 - draw.world.f[idx].uv.x[i]
				end
			end
		end

		local last = #draw.world.f
		if type == 4 and angle ~= 2 then
			draw.p_verts[1] = {draw.world.f[last - 1], draw.world.f[last]}
		elseif type == 5 and angle ~= 2 then
			draw.p_verts[2] = {draw.world.f[last - 1], draw.world.f[last]}
		end
		------
	end end end end
	--the world for blue and orange portals
	if draw.p[1] and draw.p[2] then
		for i=1,#draw.world.f do
			--blue portal
			local draw_wall=true

			if draw.p[2][4]==1 and draw.p[2][5]==1 then
				if (draw.world.f[i].w[3]>=draw.p[2][1]) --X
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==1) --X
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[5]>draw.p[2][3]) --Z
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[5]<draw.p[2][3]) --Z
				then draw_wall=false end

			elseif draw.p[2][4]==1 and draw.p[2][5]==2 then
				if (draw.world.f[i].w[3]<draw.p[2][1]) --X
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==2) --X
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[5]>draw.p[2][3]) --Z
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[5]<draw.p[2][3]) --Z
				then draw_wall=false end

			elseif draw.p[2][4]==3 and draw.p[2][5]==1 then
				if (draw.world.f[i].w[5]<draw.p[2][3]) --Z
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==1) --Z
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[3]<draw.p[2][1]) --X
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[3]>draw.p[2][1]) --X
				then draw_wall=false end

			elseif draw.p[2][4]==3 and draw.p[2][5]==2 then
				if (draw.world.f[i].w[5]>=draw.p[2][3]) --Z
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==2) --Z
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[3]<draw.p[2][1]) --X
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[3]>draw.p[2][1]) --X
				then draw_wall=false end
			end


			if (draw.world.f[i].w[2]==2 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[4]>draw.p[2][2]) --Y
			or (draw.world.f[i].w[2]==2 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[4]<draw.p[2][2]) --Y
			then draw_wall=false end

			if draw_wall then draw.world_bp.f[#draw.world_bp.f+1]=draw.world.f[i] end

			--orange portal
			local draw_wall=true

			if draw.p[1][4]==1 and draw.p[1][5]==1 then
				if (draw.world.f[i].w[3]>=draw.p[1][1]) --X
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==1) --X
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[5]>draw.p[1][3]) --Z
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[5]<draw.p[1][3]) --Z
				then draw_wall=false end

			elseif draw.p[1][4]==1 and draw.p[1][5]==2 then
				if (draw.world.f[i].w[3]<draw.p[1][1]) --X
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==2) --X
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[5]>draw.p[1][3]) --Z
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[5]<draw.p[1][3]) --Z
				then draw_wall=false end

			elseif draw.p[1][4]==3 and draw.p[1][5]==1 then
				if (draw.world.f[i].w[5]<draw.p[1][3]) --Z
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==1) --Z
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[3]<draw.p[1][1]) --X
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[3]>draw.p[1][1]) --X
				then draw_wall=false end

			elseif draw.p[1][4]==3 and draw.p[1][5]==2 then
				if (draw.world.f[i].w[5]>=draw.p[1][3]) --Z
				or (draw.world.f[i].w[2]==3 and draw.world.f[i].w[1]==2) --Z
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[3]<draw.p[1][1]) --X
				or (draw.world.f[i].w[2]==1 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[3]>draw.p[1][1]) --X
				then draw_wall=false end
			end


			if (draw.world.f[i].w[2]==2 and draw.world.f[i].w[1]==2 and draw.world.f[i].w[4]>draw.p[1][2]) --Y
			or (draw.world.f[i].w[2]==2 and draw.world.f[i].w[1]==1 and draw.world.f[i].w[4]<draw.p[1][2]) --Y
			then draw_wall=false end

			if draw_wall then draw.world_op.f[#draw.world_op.f+1]=draw.world.f[i] end
		end
	end
	--light bridge generator
	draw.objects.lb={}
	draw.world.sp={}
	if draw.lg~=0 then
		for i=1,#draw.lg do
			local lx,ly,lz=draw.lg[i][1],draw.lg[i][2],draw.lg[i][3]
			local vx,vz=0,0
			if     draw.lg[i][4]==1 and draw.lg[i][5]==1 then vx=-1 lx=lx-1
			elseif draw.lg[i][4]==1 and draw.lg[i][5]==2 then vx=1
			elseif draw.lg[i][4]==3 and draw.lg[i][5]==1 then vz=1
			elseif draw.lg[i][4]==3 and draw.lg[i][5]==2 then vz=-1 lz=lz-1 else error(draw.lg[i][4].." | "..draw.lg[i][5])
			end
			for _=1,100 do --bridge lenght limiter
				if     vx==-1 then addobj(48+lx*96,ly*128,48+lz*96,4)
				elseif vx==1  then addobj(48+lx*96,ly*128,48+lz*96,5)
				elseif vz==-1 then addobj(48+lx*96,ly*128,48+lz*96,6)
				elseif vz==1  then addobj(48+lx*96,ly*128,48+lz*96,7)
				end

				lx=lx+vx
				lz=lz+vz

				local bp=false
				local op=false
				--going through portals
				if draw.p[1] and draw.p[2] then
					--blue portal
				   if     vx==1  and draw.p[1][4]==1 and draw.p[1][5]==1 and lx  ==draw.p[1][1] and ly==draw.p[1][2] and lz  ==draw.p[1][3] then bp=true
					elseif vx==-1 and draw.p[1][4]==1 and draw.p[1][5]==2 and lx+1==draw.p[1][1] and ly==draw.p[1][2] and lz  ==draw.p[1][3] then bp=true
					elseif vz==1  and draw.p[1][4]==3 and draw.p[1][5]==2 and lx  ==draw.p[1][1] and ly==draw.p[1][2] and lz  ==draw.p[1][3] then bp=true
					elseif vz==-1 and draw.p[1][4]==3 and draw.p[1][5]==1 and lx  ==draw.p[1][1] and ly==draw.p[1][2] and lz+1==draw.p[1][3] then bp=true
					--orange portal
					elseif vx==1  and draw.p[2][4]==1 and draw.p[2][5]==1 and lx  ==draw.p[2][1] and ly==draw.p[2][2] and lz  ==draw.p[2][3] then op=true
					elseif vx==-1 and draw.p[2][4]==1 and draw.p[2][5]==2 and lx+1==draw.p[2][1] and ly==draw.p[2][2] and lz  ==draw.p[2][3] then op=true
					elseif vz==1  and draw.p[2][4]==3 and draw.p[2][5]==2 and lx  ==draw.p[2][1] and ly==draw.p[2][2] and lz  ==draw.p[2][3] then op=true
					elseif vz==-1 and draw.p[2][4]==3 and draw.p[2][5]==1 and lx  ==draw.p[2][1] and ly==draw.p[2][2] and lz+1==draw.p[2][3] then op=true
					end
					--teleporting
					if op then
						lx,ly,lz=draw.p[1][1],draw.p[1][2],draw.p[1][3]
						if     draw.p[1][4]==1 and draw.p[1][5]==2 then vz=0 vx=1
						elseif draw.p[1][4]==1 and draw.p[1][5]==1 then vz=0 vx=-1 lx=lx-1
						elseif draw.p[1][4]==3 and draw.p[1][5]==2 then vx=0 vz=-1 lz=lz-1
						elseif draw.p[1][4]==3 and draw.p[1][5]==1 then vx=0 vz=1
						end
					elseif bp then
						lx,ly,lz=draw.p[2][1],draw.p[2][2],draw.p[2][3]
						if     draw.p[2][4]==1 and draw.p[2][5]==2 then vz=0 vx=1
						elseif draw.p[2][4]==1 and draw.p[2][5]==1 then vz=0 vx=-1 lx=lx-1
						elseif draw.p[2][4]==3 and draw.p[2][5]==2 then vx=0 vz=-1 lz=lz-1
						elseif draw.p[2][4]==3 and draw.p[2][5]==1 then vx=0 vz=1
						end
					end
				end
				--if the bridge collides with a wall, we stop the loop
				if lx<0 or lx>world_size[1]-1 or lz<0 or lz>world_size[3]-1 then draw.pr_g[#draw.pr_g+1]={lx,ly,lz,vx,vz} break end
				if not (bp or op) then
				if     (vx==1  and draw.map[1][lx  ][ly][lz  ][2]~=0 and draw.map[1][lx  ][ly][lz  ][2]~=3 and draw.map[1][lx  ][ly][lz  ][2]~=15)
				or (vx==-1 and draw.map[1][lx+1][ly][lz  ][2]~=0 and draw.map[1][lx+1][ly][lz  ][2]~=3 and draw.map[1][lx+1][ly][lz  ][2]~=15)
				or (vz==1  and draw.map[3][lx  ][ly][lz  ][2]~=0 and draw.map[3][lx  ][ly][lz  ][2]~=3 and draw.map[3][lx  ][ly][lz  ][2]~=15)
				or (vz==-1 and draw.map[3][lx  ][ly][lz+1][2]~=0 and draw.map[3][lx  ][ly][lz+1][2]~=3 and draw.map[3][lx  ][ly][lz+1][2]~=15) then draw.pr_g[#draw.pr_g+1]={lx,ly,lz,vx,vz} break
				end end
			end
		end
	end
end

local function load_world(set_id,world_id) --Loads the world from ROM memory (from the 'Maps' table)
	--init
	draw.map={}
	draw.world={v={},f={},sp={}}
	draw.p[1]=nil
	draw.p[2]=nil
	draw.pr={}
	draw.pr_g={}
	draw.lg={}
	draw.objects={
		c={}, --cubes
		cd={}, --cube dispensers
		lb={}, --light bridges
		b={}, --buttons
		t={} --turrets
	}

	for z=0,world_size[1]-1 do for y=0,world_size[2]-1 do for x=0,world_size[3]-1 do
		table.insert(draw.world.v,{x*96,y*128,z*96})
	end end end

	for i=1,4 do
		q3={}
		for x=0,world_size[1]-1 do
			q2={}
			for y=0,world_size[2]-1 do
				q={}
				for z=0,world_size[3]-1 do
					q[z]={0,0}
				end
				q2[y]=q
			end
			q3[x]=q2
		end
		draw.map[i]=q3
	end

	--foolproof
	if maps[set_id]==nil then
		error("Unknown ID set of levels: "..set_id)
	elseif maps[set_id][world_id]==nil then
		error("Unknown ID of the world: "..set_id.." "..world_id)
	end
	----
	for i=1,#maps[set_id][world_id].w do
		addwall(maps[set_id][world_id].w[i][1],maps[set_id][world_id].w[i][2],maps[set_id][world_id].w[i][3],maps[set_id][world_id].w[i][4],maps[set_id][world_id].w[i][5],maps[set_id][world_id].w[i][6])
	end
	for i=1,#maps[set_id][world_id].o do
		addobj(maps[set_id][world_id].o[i][1],maps[set_id][world_id].o[i][2],maps[set_id][world_id].o[i][3],maps[set_id][world_id].o[i][4],maps[set_id][world_id].o[i][5])
	end
	for i=1,#maps[set_id][world_id].lg do
		draw.lg[i]=maps[set_id][world_id].lg[i]
	end

	if maps[set_id][world_id].p then
		draw.p=maps[set_id][world_id].p
	end
	--lift
	for i=1,2 do
		if maps[set_id][world_id].lift[i] then
			local x0, y0, z0=maps[set_id][world_id].lift[i][1], maps[set_id][world_id].lift[i][2], maps[set_id][world_id].lift[i][3]
			addwall(x0,y0  ,z0,2,2,1)
			addwall(x0,y0+1,z0,2,1,1)

			if     maps[set_id][world_id].lift[i][4]==0 then addwall(x0,y0,z0,1,2,18)addwall(x0+1,y0,z0,1,1,18)addwall(x0,y0,z0,3,3,19)addwall(x0,y0,z0+1,3,2,18)
			elseif maps[set_id][world_id].lift[i][4]==1 then addwall(x0,y0,z0,1,3,19)addwall(x0+1,y0,z0,1,1,18)addwall(x0,y0,z0,3,1,18)addwall(x0,y0,z0+1,3,2,18)
			elseif maps[set_id][world_id].lift[i][4]==2 then addwall(x0,y0,z0,1,2,18)addwall(x0+1,y0,z0,1,1,18)addwall(x0,y0,z0,3,1,18)addwall(x0,y0,z0+1,3,3,19)
			elseif maps[set_id][world_id].lift[i][4]==3 then addwall(x0,y0,z0,1,2,18)addwall(x0+1,y0,z0,1,3,19)addwall(x0,y0,z0,3,1,18)addwall(x0,y0,z0+1,3,2,18)
			else error()
			end
		end
	end
	----
	update_world()
end
--palette
local pal="0000001c181c3838385d5d5d7d7d7dbababad6d6d6fffffff21018ff55553499ba65eef6b2f6fad67918ffbe3cff00ff"
function respal()
	for i=1,#pal,2 do
		poke(0x3FC0+i//6*3+i//2%3,tonumber(pal:sub(i,i+1),16))
	end
end

function updpal(r,g,b)
	for i=0,47,3 do
		poke(0x03FC0+i,peek(0x03FC0+i)*r) --RED
		poke(0x03FC1+i,peek(0x03FC1+i)*b) --BLUE
		poke(0x03FC2+i,peek(0x03FC2+i)*g) --GREEN
	end
end

function darkpal(c)
	for i=0,47 do --RGB
		poke(0x03FC0+i,peek(0x03FC0+i)*c)
	end
end

local avf={} --average frame
local fr={0,0,0} --framerate
t1=0 --The start time of the frame drawing
t2=0 --The time for drawing the current frame
t=0 -- Global timer (+1 for each code call)
stt=0 --The timer of the start of the game
--player speed
local speed=4
--init
local tm1,tm2 = 0,0
local p={t=0,t1=1,t2=1,t3=1,t4=1,t5=1,t6=1} --pause
local ls={t=0,pr=0} --loading screen
local sts={t=1,time={1,2,0,0},i=0,t2=0,sl=50,q=1,y=0,n=0} --start screen
local l_={t=0} --logo
local ms={t=0,t1=1,t2=1,t3=1,t4=1,t5=1,t6=1,t7=1,t8=1,t9=1} --main screen
local is={t=0,t1=0,t2=0} --init setting

local open="logo" sync(1,1,false)
function TIC()
	--fps counter
	t1 = time()
	t = t + 1
	--mouse
	local mx, my, cl1, _, cl2 = mouse()
	local cid=0 --cursor id

	if cl1 then tm1 = tm1 + 1 else tm1 = 0 end
	if cl2 then tm2 = tm2 + 1 else tm2 = 0 end

	clp1 = tm1 == 1
	clp2 = tm2 == 1
	--trace(mx.." "..my,12)
	--------------------------
	-- logo ------------------
	--------------------------
	if open=="logo" then
		l_.t=l_.t+1
		--GUI
		cls(1)
		spr(112,88,24,0,1,0,0,8,9)
		print("Powered by Unitic 1.3",66,113,7)
		--pal
		respal()
		if l_.t<60 then darkpal(min(l_.t/30,1))
		elseif l_.t<90 then darkpal((90-l_.t)/30) end
		if l_.t>=90 or (keyp() and l_.t>10) then
			sync(1,0,false)
			load_world(0,1)
			if save.st&2^31==0 then open="init setting" else open="main" music(2) end
		end
	end
	--------------------------
	-- Initial setting -------
	--------------------------
	if open=="init setting" then respal()
		is.t=is.t+1
		if is.t==2 then
			is.t1=time()
			for i=1,300 do
				cam.x=R(-999,999)
				cam.y=R(-999,999)
				cam.z=R(-999,999)
				cam.tx=R(-99,99)
				cam.ty=R(-99,99)
				unitic.update()
				unitic.draw()
				if time()-is.t1>2000 then is.t1=is.t1-5000 break end
			end
			is.t1=time()-is.t1
		end
		cls(1)
		if is.t<3 then
			print("perfomance evaluation",60,113,7)
			print("please wait...",86,103,7)
		else
			print("The following recommended",47,5,7)
			print("parameters were selected:",47,15,7)
			local p=F(1/is.t1*200000) --points
			local text_size=print("Evaluation result: "..p.." points.",240,0)
			print("Evaluation result: "..p.." points.",120-text_size//2,105,2)
			
			rect(0,28,240,21,2)
			if is.t1>300 then
				print("Rendering of both portals is chosen",23,36,0)
				print("Rendering of both portals is chosen",23,35,7)
				st.d_r=true
				st.r_both=true
			elseif is.t1>180 then
				print("Rendering of one portal is chosen",30,36,0)
				print("Rendering of one portal is chosen",30,35,7)
				st.d_r=true
				st.r_both=false
			else
				print("The rendering of portals is disabled",23,36,0)
				print("The rendering of portals is disabled",23,35,7)
				st.d_r=false
				st.r_both=false
			end
			
			print("You can always configure this",41,65,4)
			print("later in the settings menu",49,75,4)

			rect(94,122,41,8,2)
			print("Accept",97,123,7)
			if mx>93 and my>122 and mx<134 and my<131 then cid=1 if clp1 then music(2) open="main" clp1=false end end
		end
	end
	--------------------------
	-- main screen -----------
	--------------------------
	if open=="main" or open=="main|newgame" or open=="main|authors" or open=="main|settings" or open=="main|skilltest" then
		ms.t=ms.t+1
		--camera
		vbank(0)
		cam.x=40
		cam.y=96
		cam.z=525
		cam.tx=math.sin(ms.t/50)*0.05+0.2
		cam.ty=math.sin(ms.t/100)*0.1-math.pi/4
		unitic.update()
		unitic.draw()

		--GUI
		vbank(1) cls(0)
		if open~="main|settings" then spr(256,min(-104+ms.t*6,8),4,0,1,0,0,13,3) end

		if open=="main" then
			if not save.i then print("Continue"  ,min(ms.t*2-10,4)+(1-ms.t1)*20, 45,7) end
			print("New game"  ,min(ms.t*2-20,4)+(1-ms.t2)*20, 55,7)
			print("Skill test",min(ms.t*2-30,4)+(1-ms.t3)*20, 75,7)
			print("Settings"  ,min(ms.t*2-40,4)+(1-ms.t4)*20, 95,7)
			print("Authors"   ,min(ms.t*2-50,4)+(1-ms.t5)*20,105,7)
			print("Exit"      ,min(ms.t*2-60,4)+(1-ms.t6)*20,125,7)
			--version
			local text_size=print("version "..version,240,0)
			print("version "..version,238-text_size,130,7)
			vbank(0)
			--buttons
 			if my>42  and my<53  and not save.i then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then open="load lvl" save.lvl2=1 end else ms.t1=min(1,ms.t1+0.05) end

			if my>52  and my<63  then cid=1 ms.t2=max(ms.t2-0.05,0.5) if clp1 then if save.i then open="load lvl" save.lvl2=1 music() else open="main|newgame" sfx(16) ms.t1=1 ms.t2=1 end end else ms.t2=min(1,ms.t2+0.05) end

			if my>72  and my<83  then cid=1 ms.t3=max(ms.t3-0.05,0.5) if clp1 then open="main|skilltest" end else ms.t3=min(1,ms.t3+0.05) end

			if my>92  and my<103 then cid=1 ms.t4=max(ms.t4-0.05,0.5) if clp1 then open="main|settings" sfx(16) ms.t1=1 end else ms.t4=min(1,ms.t4+0.05) end
			if my>102 and my<113 then cid=1 ms.t5=max(ms.t5-0.05,0.5) if clp1 then open="main|authors" sfx(16) ms.t1=1 end else ms.t5=min(1,ms.t5+0.05) end
			if my>122 and my<133 then cid=1 ms.t6=max(ms.t6-0.05,0.5) if clp1 then exit() end else ms.t6=min(1,ms.t6+0.05) end

		elseif open=="main|newgame" then
			print("Warning",4,35,8)
			print("Your current save",4,45,7)
			print("will be removed.",4,55,7)
			print("Continue?",4,65,7)

			print("Accept",4+(1-ms.t1)*20,85,7)
			print("Cancel",4+(1-ms.t2)*20,105,7)
			if my>82  and my<93  then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then open="load lvl" save.lvl=0 save.ct=0 pmem(0,0)pmem(2,0)pmem(3,0)pmem(4,0) end else ms.t1=min(1,ms.t1+0.05) end
			if my>102 and my<113 then cid=1 ms.t2=max(ms.t2-0.05,0.5) if clp1 then sfx(17) open="main" ms.t1=1 ms.t2=1 ms.t3=1 ms.t4=1 ms.t5=1 ms.t6=1 end else ms.t2=min(1,ms.t2+0.05) end
		elseif open=="main|skilltest" then
			print("Set of skilltest levels",1,35,7)
			print("Take these levels",1,55,13)
			print("as quickly as possible",1,65,13)
			local bt=""
			if save.bt//60<10 then bt=bt.."0"..save.bt//60 ..":" else bt=bt..save.bt//60 ..":" end
			if save.bt% 60<10 then bt=bt.."0"..save.bt%60 else bt=bt..save.bt%60 end

			print("Your record: "..bt,1,85,11)
			print("Start game",4+(1-ms.t1)*20,105,7)
			print("Back",4+(1-ms.t2)*20,125,7)
			if my>102 and my<112 then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then open="load lvl" music(3) ctp=0 save.lvl2=2 end else ms.t1=min(1,ms.t1+0.05) end
			if my>122 and my<132 then cid=1 ms.t2=max(ms.t2-0.05,0.5) if clp1 then sfx(17) open="main" ms.t1=1 ms.t2=1 ms.t3=1 ms.t4=1 ms.t5=1 ms.t6=1 end else ms.t2=min(1,ms.t2+0.05) end

		elseif open=="main|authors" then
			print("3D engine: UniTIC v 1.3 (MIT license)"   ,1,45,7)
			print("Author of the engine: HanamileH"         ,1,55,7)
			print("Coders:             HanamileH & soxfox42",1,75,7)
			print("Level designers: [Random dude]"          ,1,85,7)
			print("Testers:            [Random dude]"       ,1,95,7)
			print("Back",4+(1-ms.t1)*20,115,7)
			if my>112 and my<123 then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then sfx(17) open="main" ms.t1=1 ms.t2=1 ms.t3=1 ms.t4=1 ms.t5=1 ms.t6=1 end else ms.t1=min(1,ms.t1+0.05) end
		end
	end
	--------------------------
	-- calibration -----------
	--------------------------
	if open=="calibration" then vbank(1) cls() respal() vbank(0) respal()
		if sts.t2>0 then sts.t2=sts.t2-1 end
		cls(1)

		if clp1 then sfx(16) end
		--
		if sts.t==1 then
			print("Enter the current time.",51,3,7)
			print(sts.time[1]..sts.time[2]..":"..sts.time[3]..sts.time[4],80,50,6,true,2)
			if sts.i<2 then
			line(79+sts.i*12,61,91+sts.i*12,61,7)
			else
			line(79+sts.i*12+12,61,91+sts.i*12+12,61,7)
			end

			if keyp(1) or btnp(2) then sts.i=sts.i-1 end
			if keyp(4) or btnp(3) then sts.i=sts.i+1 end
			sts.i=sts.i%4

			if keyp(23) or btnp(0) then sts.time[sts.i+1]=sts.time[sts.i+1]+1 end
			if keyp(19) or btnp(1) then sts.time[sts.i+1]=sts.time[sts.i+1]-1 end

			sts.time[1]=sts.time[1]%3 sts.time[1]=sts.time[1]*10+sts.time[2]
			sts.time[1]=sts.time[1]%24 sts.time[2]=sts.time[1]%10 sts.time[1]=sts.time[1]//10
			sts.time[3]=sts.time[3]%6 sts.time[4]=sts.time[4]%10
		end
		--confirm button
		if sts.t2==0 and sts.t~=2 and (sts.t<8  or sts.t==16) then
			rect(94,122,40,8,2)
			print("Confirm",95,123,7)
			if mx>93 and my>121 and mx<134 and my<131 then cid=1 if clp1 then sts.t=sts.t+1 sts.t2=60 sts.sl=R(0,99) end end
		end
		--Yes/no button
		if sts.t2==0 and (sts.t==2 or sts.t>7) and sts.t~=16 and sts.t~=32 then
			rect(67,122,18,8,2)
			rect(143,122,13,8,2)
			print("Yes",68,123,7)
			print("No",144,123,7)
			if mx>66  and my>121 and mx<85  and my<131 then cid=1 if clp1 then sts.y=sts.y+1 sts.q=1 sts.t=sts.t+1 sts.t2=60 sts.sl=R(0,99) end end
			if mx>143 and my>121 and mx<156 and my<131 then cid=1 if clp1 then sts.n=sts.n+1 sts.q=2 sts.t=sts.t+1 sts.t2=60 sts.sl=R(0,99) end end
		end
		--slider
		if (sts.t>2 and sts.t<8) or sts.t==16 then
			rect(20,88,180,2,2)
			rect(20+sts.sl*1.8,85,2,8,6)
			if mx>19 and my>85 and mx<200 and my<93 then cid=1 if cl1 then sts.sl=(mx-20)/1.8 end end
		end
		--Number on the slider
		if (sts.t>3 and sts.t<8) or sts.t==16 then
			print(F(sts.sl+0.5),100,68,7,false,2)
		end

		------------
		if sts.t==2 then
			print("Is this the exact time?",51,3,7)
			print(sts.time[1]..sts.time[2]..":"..sts.time[3]..sts.time[4],98,65,6,true,1)
		end

		if sts.t==3 then
			print("How accurate is this time?",51,3,7)
			print(sts.time[1]..sts.time[2]..":"..sts.time[3]..sts.time[4],98,65,6,true,1)
			print("not accurate",12,76,7)
			print("accurate",160,76,7)
		end

		if sts.t==4 then print("Pull the slider until the given number becomes prime",29,3,7,false,1,true) end
		if sts.t==5 then print("Pull the slider until the number becomes more than 50",29,3,7,false,1,true) end
		if sts.t==6 then print("How many numbers from 0 to 100 have 3 divisors exist?",29,3,7,false,1,true) end
		if sts.t==7 then print("Pull the slider until the number becomes completely by chance",11,3,7,false,1,true) end
		if sts.t==8 then print("Do you know the authors of this game?",19,3,7,false,1,false) end
		if sts.t==9 then print("Do the authors of this game know you?",19,3,7,false,1,false) end
		if sts.t==11 then
			if sts.q==1 then
				print([[Have you just answered "yes" to the last empty question?]],19,3,7,false,1,true)
			else
				print([[Have you just answered "no" to the last empty question?]],19,3,7,false,1,true)
			end
		end
		if sts.t==12 then
			if sts.q==1 then
				print([[Why did you answer "yes"]].."\n\n "..[[to the last question?]],55,3,7,false,1,false)
			else
				print([[Why did you answer "no"]] .."\n\n "..[[to the last question?]],55,3,7,false,1,false)
			end
		end
		if sts.t==13 then print("Do you consider yourself happy?",30,3,7,false,1,false) end
		if sts.t==14 then print("Have you ever thought that you have mental disorders?",20,3,7,false,1,true) end
		if sts.t==15 then print("Do you think you have a lot of friends?",10,3,7,false,1,false) end
		if sts.t==16 then print("How many friends do you have?",35,3,7,false,1,false) end
		if sts.t==17 then print("Do you really like this game?",35,3,7,false,1,false) end
		if sts.t==18 then print("Have you answered the truth?",35,3,7,false,1,false) end
		if sts.t==19 then print("Do you want to start the game?",35,3,7,false,1,false) end
		if sts.t==20 then print("Do you like this survey?",40,3,7,false,1,false) end
		if sts.t==21 then print("Are you positive to the chairs?",35,3,7,false,1,false) end
		if sts.t==22 then print("Is there a Chinese layout on your keyboard?",1,3,7,false,1,false) end
		if sts.t==23 then print("Why?",107,3,7,false,1,false) end
		if sts.t==24 then print("_",107,3,7,false,1,false) end
		if sts.t==27 then print("Have you ever found HanamileH\n\n   rather cute and pretty?",42,3,7,false,1,false) end
		if sts.t==28 then print(" Have you ever had dreams with\n\nthe participation of HanamileH?",36,3,7,false,1,false) end
		if sts.t==29 then print("Would you like to ever meet HanamileH live?",6,3,7,false,1,false) end
		if sts.t==30 then print("Why are you still answering this survey?",10,3,7,false,1,false) end
		if sts.t==31 then print("Do you want me to help you?",44,3,7,false,1,false) end
		if sts.t==32 then
			print("Press any button to start the game",22,3,7,false,1,false)

			clip(1,10,238,125)
			for x=0,240,23 do for y=0,135,13 do
				local dx,dy=x-mx+10,y-my+5
				local d=(dx^2+dy^2)^0.5

				local px,py=mx+dx*(20/d+1),my+dy*(20/d+1)

				rect(px-1,py-1,19,9,4)
				print("any",px,py+1,0)
				print("any",px,py,7)
			end end
			clip()
			rectb(1,10,238,125,2)

			if mx>54 and my>2 and mx<75 and my<10 then cid=1 if clp1 then sts.t=33 sts.t2=60 end end
		end
		if sts.t==33 then
			print("Your statistics:",73,3,7,false,1,false)
			print("Press the buttons \"yes\": "..sts.y.." times",31,34,7)
			print("Press the buttons \"no\" : "..sts.n.." times",31,44,7)
			print("Are you satisfied with your results?",20,97,7)
		end

		if sts.t==35 then open="main|settings" music(2) end
	end
	--------------------------
	-- loading ---------------
	--------------------------
	if open=="load" then vbank(1) cls() vbank(0) respal()
		cls(1)
		ls.t=ls.t+1
		--progressbar
		rectb(1,133,237,2,2)
		rectb(1,133,ls.pr/100*237,2,7)
		ls.pr=min(ls.pr+2,100)
		--text
		print("Please wait...",80,125,7)
		--animation
		clip(200,30,24,90)
		spr(425,200,30+ls.t*3%90,-1,1,0,0,3,3)
		spr(425,200,30+ls.t*3%90-90,-1,1,0,0,3,3)
		clip()
		rect(193,28,38,2,10)
		rect(193,118,38,2,13)
	end
	--------------------------
	-- load lvl --------------
	--------------------------
	if open=="load lvl" then
		if st_t then save.ct=save.ct+(tstamp()-st_t) end
		pmem(4,save.ct)

		if save.lvl==0 then save.lvl=1 end
		save.lvl2=0
		save.lvl=2 --debug

		pmem(0,save.lvl)
		load_world(save.lvl2,save.lvl)
		plr.hp=100
		plr.hp2=100
		if maps[save.lvl2][save.lvl].lift[1] then
			plr.x=maps[save.lvl2][save.lvl].lift[1][1]*96+48
			plr.y=maps[save.lvl2][save.lvl].lift[1][2]*128+64
			plr.z=maps[save.lvl2][save.lvl].lift[1][3]*96+48
			plr.tx=0
			plr.ty=pi2*maps[save.lvl2][save.lvl].lift[1][4]
		else
			plr.x=32
			plr.y=64
			plr.z=32
			plr.tx=0
			plr.ty=0
		end

		if save.lvl2~=2 then music(maps[save.lvl2][save.lvl].music) end

		mx,my=0,0
		poke(0x7FC3F,1,1)
		plr.d=false
		open="game"
		stt=0
		lctp=ctp or 0
		ctp=0  --current time passing
		st_t=tstamp() --The start time of this level
	end
	--------------------------
	-- pause -----------------
	--------------------------
	if open=="pause" or open=="pause|settings" or open=="pause|accept" then
		p.t=p.t+1
		--GUI
		vbank(0)
		memcpy(0x0,0x8000,240*136/2)
		vbank(1)
		cls(0)
		--logo
		if open~="pause|settings" then spr(256,min(-104+p.t*6,8),4,0,1,0,0,13,3) end

		if open=="pause" then
			print("Pause"        ,min(p.t*2,37), 35,7)
			print("Resume"       ,4+(1-p.t1)*20, 55,7)
			print("Restart level",4+(1-p.t2)*20, 65,7)
			print("Settings"     ,4+(1-p.t3)*20, 85,7)
			print("Exit"         ,4+(1-p.t4)*20,125,7)
			--buttons
			if my>52  and my<63  then p.t1=max(p.t1-0.05,0.5) cid=1
				if clp1 then
					open="game"
					sfx(17)
					poke(0x7FC3F,1,1)
					if save.lvl2~=2 then music(maps[save.lvl].music) else music(3) end
					lctp=ctp or 0
					ctp=0
					st_t=tstamp()
				end 
			else p.t1=min(p.t1+0.05,1) end

			if my>62  and my<73  then p.t2=max(p.t2-0.05,0.5) cid=1 if clp1 then open="load lvl"                                                  end else p.t2=min(p.t2+0.05,1) end
			if my>82  and my<93  then p.t3=max(p.t3-0.05,0.5) cid=1 if clp1 then open="pause|settings" sfx(16) clp1=false                         end else p.t3=min(p.t3+0.05,1) end
			if my>122 and my<133 then p.t4=max(p.t4-0.05,0.5) cid=1 if clp1 then open="pause|accept" sfx(16) end                                      else p.t4=min(p.t4+0.05,1) end
		elseif open=="pause|accept" then
			print("Do you really want to leave the game?",4,45,7)
			print("Your current game will not be saved",4,55,7)
			print("Accept",4+(1-p.t1)*20,85,7)
			print("Back"  ,4+(1-p.t2)*20,105,7)
			if my>82  and my<93  then p.t1=max(p.t1-0.05,0.5) cid=1 if clp1 then open="main" poke(0x7FC3F,1,0) music(2) load_world(0,1) end else p.t1=min(p.t1+0.05,1) end
			if my>102 and my<113 then p.t2=max(p.t2-0.05,0.5) cid=1 if clp1 then open="pause" sfx(17)                               end else p.t2=min(p.t2+0.05,1) end
		end

		--Resume button
		if keyp(44) and p.t>1 then open="game" music(maps[save.lvl].music) poke(0x7FC3F,1,1) end
	end
	--------------------------
	-- game ------------------
	--------------------------
	if open=="game" then
		if keyp(21) then draw.objects.c = {{type=1, x=500,y=200,z=96, vx=0, vy=0, vz=0, draw=true, model=model[1]},{type=1, x=500,y=200,z=96, vx=0, vy=0, vz=0, draw=true, model=model[2]}} end
		if draw.objects.c[1] then
			if btn(0) then draw.objects.c[1].vx = 5 elseif btn(1) then draw.objects.c[1].vx = -5 else draw.objects.c[1].vx = 0 end
			if btn(2) then draw.objects.c[1].vz = 5 elseif btn(3) then draw.objects.c[1].vz = -5 else draw.objects.c[1].vz = 0 end
		end
		
		if stt~=120 then stt=stt+1 end
		fps_.t1=time()
		plr.cd2=max(plr.cd2-1,0)
		plr.cd3=max(plr.cd3-1,0)
	 --W A S D
		lx, ly, lz = plr.x, plr.y, plr.z
		if (plr.cd3==0 or R()>0.05) and not plr.d then
			if key(23) then plr.z = plr.z - math.cos(plr.ty) * speed plr.x = plr.x - math.sin(plr.ty) * speed end
			if key(19) then plr.z = plr.z + math.cos(plr.ty) * speed plr.x = plr.x + math.sin(plr.ty) * speed end
			if key(1) then plr.z = plr.z - math.cos(plr.ty - pi2) * speed plr.x = plr.x - math.sin(plr.ty - pi2) * speed end
			if key(4) then plr.z = plr.z + math.cos(plr.ty - pi2) * speed plr.x = plr.x + math.sin(plr.ty - pi2) * speed end
		end

		if plr.cd3==0 and key(64) then speed = 8 else speed = 4 end
		if plr.noclip then speed=12 end
		if keyp(57) or keyp(22) then plr.noclip = not plr.noclip end
		if keyp(2) then plr.godmode = not plr.godmode end
	--jump
		if plr.noclip and not plr.d then
			if key(48) then plr.y = plr.y + 8 end
			if key(63) then plr.y = plr.y - 8 end
			plr.vy=0
		elseif not plr.d then
			if plr.xy then plr.vy=-1
				if keyp(48) then plr.vy = 8 end
			end
			plr.y = plr.y + plr.vy
			plr.vy=max(plr.vy-0.5,-20)
		end
	 --palette
		for i=0,1 do
		vbank(i)
			respal()
			if plr.hp<40 then
				updpal(1,max(abs(math.sin(time()/200))*0.7+0.3,plr.hp/50),max(abs(math.sin(time()/200))*0.7+0.3,plr.hp/50))
			end
			if plr.cd2>0 then
				updpal((10-plr.cd2)/10*0.7+0.3,1,1)
			end
			if plr.cd3>0 then
				updpal(1,0.2*(3-plr.cd3*0.2),0.2*(3-plr.cd3*0.2))
			end
			if stt<60 then
				darkpal(stt/60)
			elseif stt>120 then
				darkpal(max(0,150-stt)/30)
			end
		end
	 --camera rotation
	 	if p.t==0 and stt>2 then
			plr.tx = plr.tx + my/(140-st.m_s)
			plr.ty = plr.ty + mx/(140-st.m_s)
	 	end
		plr.ty = plr.ty%(math.pi*2)
		plr.tx = max(min(plr.tx, pi2), -pi2)
	 --update + collision
		fps_.t2=time()
		if not plr.d then unitic.player_collision() end
		unitic.portal_collision()
		unitic.cube_update()
		unitic.button_update()
		unitic.turret_update()
		fps_.t3=time()
	 --render
		unitic.render()
	 --portal gun
		pcall(portal_gun)
	 --sounds
		s.t1=max(s.t1-1,0)
		if (key(23) or key(19) or key(1) or key(4)) and s.t1==0 then sfx(1) if key(64) then s.t1=15 else s.t1=20 end end
		if plr.cd2==8 then sfx(3,"B-4",-1,1) end
	 --hp
		if plr.hp2 == plr.hp then plr.cd=plr.cd+1 else plr.cd=0 end
		if plr.cd>120 then plr.hp=min(plr.hp+1,100) end
		if plr.y<-400 then plr.hp=max(plr.hp-2,0) end
		plr.hp2 = plr.hp
		if plr.godmode then plr.hp=100 end
	 --finish lift
		if not plr.d and plr.x//96==maps[save.lvl2][save.lvl].lift[2][1] and plr.y//128==maps[save.lvl2][save.lvl].lift[2][2] and plr.z//96==maps[save.lvl2][save.lvl].lift[2][3] then stt=max(stt,121)end
		if stt>150 then open="load lvl" if plr.d then save.lvl=save.lvl-1 end end
	 --death
	 	if plr.hp<=0 then
			plr.d=true
			stt=max(stt,121)
		end
	 --text
		local text="Level "..save.lvl
		local text_size=print(text,240,0)
		if stt<60 then
			print(text:sub(1,stt//4),120-text_size/2,91,1)
			print(text:sub(1,stt//4),120-text_size/2,90,7)
		elseif stt<120 then
			print(text:sub(1,(59-stt)//4),120-text_size/2,91,1)
			print(text:sub(1,(59-stt)//4),120-text_size/2,90,7)
		end
		
		local text=""
		if ctp//60<10 then text=text.."0"..ctp//60 ..":" else text=text..ctp//60 ..":" end
		if ctp% 60<10 then text=text.."0"..ctp%60 else text=text..ctp%60 end

		local text_size=print(text,240,0,true)

		print(text,120-text_size/2,131,1,true)
		print(text,120-text_size/2,130,7,true)
	 --
		ctp=F(lctp+(tstamp()-st_t))
		pmem(4,save.ct+(tstamp()-st_t))
	 --pause
		if keyp(44) and p.t==0 then vbank(1) memcpy(0x8000,0x0000,240*136/2) vbank(0) open="pause" music(3,7,0) poke(0x7FC3F,0,1) end
		p.t=0
	 --debug
	 	local debug_text={
			{
				"FPS:  " .. F(1000 / (fr[3]+fr[2])*2),
			},
			{
				"FPS:  " .. F(1000 / fr[1]).."|"..F(1000 / (fr[3]+fr[2])*2).." Frame:"..F(fr[1]+0.5).."|"..F((fr[3]+fr[2])/2+0.5),
			},
			{
				"FPS:  " .. F(1000 / fr[1]).."|"..F(1000 / (fr[3]+fr[2])*2).." Frame:"..F(t2).." ms.",
				"Av: "..F(fr[1]+0.5).."|"..F((fr[3]+fr[2])/2+0.5).." ms. min: "..F(fr[2]+0.5).." ms. max: "..F(fr[3]+0.5).." ms.",
				"Other:"..max(F((fps_.t4-fps_.t3)+(fps_.t9-fps_.t8)),0).." ms. portals:"..F(fps_.t5-fps_.t4).."|"..F(fps_.t6-fps_.t5).." ms.",
				"Update:"..F(fps_.t7-fps_.t6).." ms. draw:"..F(fps_.t8-fps_.t7).." ms."
			},
			{
				"v: " .. #unitic.poly.v .. " f:" .. #unitic.poly.f .." sp:" .. #unitic.poly.sp.." p:" .. #unitic.p.." | objects:"..#unitic.obj,
				#draw.objects.c.." "..#draw.objects.cd.." "..#draw.objects.lb.." "..#draw.objects.b,
				"camera X:" .. F(plr.x) .. " Y:" .. F(plr.y) .. " Z:" .. F(plr.z),
			}
		}
		if keyp(49) then plr.dt=plr.dt%#debug_text+1 end

		vbank(1)
			for i=1,#debug_text[plr.dt] do
				local text_size=print(debug_text[plr.dt][i], 240,0)
				rect(0,7*(i-1),text_size+2,8,2)
				print(debug_text[plr.dt][i], 1, 2+7*(i-1), 1)
				print(debug_text[plr.dt][i], 1, 1+7*(i-1), 7)
			end

			if plr.godmode then print("Godmode" ,1,130,7) else print("HP: "..plr.hp,1,130,7) end

			if plr.noclip then print("Noclip", 104, 85, 7) end
		vbank(0)
	end
	--------------------------
	-- settings menu ---------
	--------------------------
	if open=="main|settings" or open=="pause|settings" then vbank(1) cls(0)
		print("Mouse sensitivity: "..F(st.m_s),4,5,7)
		print("Music: "                  ,4,25,7)
		print("Sfx: "                    ,4,35,7)
		print("Rendering portals: "      ,4,45,7)
		print("High quality portals: "   ,4,55,7)
		print("Render both poratls:  "   ,4,65,7)
		print("Particles:  "             ,4,75,7)
		print("Dynamic textures:  "      ,4,85,7)

		print("Back"                     ,4,125,7)

		if open=="main|settings" then print("Calibration",4,105,7) end
		--on / off
		if st.music  then print("On",117,25,13) else print("Off",117,25,11) end
		if st.sfx    then print("On",117,35,13) else print("Off",117,35,11) end
		if st.r_p    then print("On",117,45,13) else print("Off",117,45,11) end
		if st.h_q_p  then print("On",117,55,13) else print("Off",117,55,11) end
		if st.r_both then print("On",117,65,13) else print("Off",117,65,11) end
		if st.p      then print("On",117,75,13) else print("Off",117,75,11) end
		if st.d_t    then print("On",117,85,13) else print("Off",117,85,11) end
		--mouse sensitivity slider
		rect(4,45-30,100,2,3)
		rect(4+st.m_s-20,43-30,2,6,6)

		if my>10 and my<24 then cid=1 if cl1 then st.m_s=max(min(mx+20-4,120),20) end end
		--buttons
		if my>22  and my<33  then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then sfx(18) if open=="main|settings" then music(2)else music(3,7,0)end st.music=not st.music end else ms.t1=min(1,ms.t1+0.05) end
		if my>32  and my<43  then cid=1 ms.t2=max(ms.t2-0.05,0.5) if clp1 then sfx(18) st.sfx   =not st.sfx           end else ms.t2=min(1,ms.t2+0.05) end
		if my>42  and my<53  then cid=1 ms.t3=max(ms.t3-0.05,0.5) if clp1 then sfx(18) st.r_p   =not st.r_p           end else ms.t3=min(1,ms.t3+0.05) end
		if my>52  and my<63  then cid=1 ms.t4=max(ms.t4-0.05,0.5) if clp1 then sfx(18) st.h_q_p =not st.h_q_p         end else ms.t4=min(1,ms.t4+0.05) end
		if my>62  and my<73  then cid=1 ms.t5=max(ms.t5-0.05,0.5) if clp1 then sfx(18) st.r_both=not st.r_both        end else ms.t5=min(1,ms.t5+0.05) end
		if my>72  and my<83  then cid=1 ms.t6=max(ms.t6-0.05,0.5) if clp1 then sfx(18) st.p     =not st.p             end else ms.t6=min(1,ms.t6+0.05) end
		if my>82  and my<93  then cid=1 ms.t7=max(ms.t7-0.05,0.5) if clp1 then sfx(18) st.d_t   =not st.d_t           end else ms.t7=min(1,ms.t7+0.05) end

		if my>102 and my<113 and open=="main|settings" then cid=1 ms.t8=max(ms.t8-0.05,0.5) if clp1 then sfx(16) music(3,7,0)open="calibration" end else ms.t8=min(1,ms.t8+0.05) end

		if my>122 and my<133 then cid=1 ms.t9=max(ms.t9-0.05,0.5)
			if clp1 then sfx(17)
				if open=="main|settings" then open="main" else open="pause" end
				ms.t1=1 ms.t2=1 ms.t3=1 ms.t4=1 ms.t5=1 ms.t6=1 ms.t7=1 ms.t8=1 ms.t9=1 end
		else ms.t9=min(1,ms.t9+0.05) end
		--saving the settings
		save.st=0
		if st.r_p    then save.st=save.st+2^0 end
		if st.h_q_p  then save.st=save.st+2^1 end
		if st.music  then save.st=save.st+2^2 end
		if st.sfx    then save.st=save.st+2^3 end
		if st.r_both then save.st=save.st+2^4 end
		if st.p      then save.st=save.st+2^5 end
		if st.d_t    then save.st=save.st+2^6 end
		save.st=save.st+2^31
		pmem(1,save.st)
	end
	--------------------------
	-- still alive -----------
	--------------------------
	if open=="still alive" then
		cls(0)
		rectb(1,1,120,133,13)
		rectb(122,1,117,65,13)
		print("music by HanamileH",124,3,13)
		print("midi by Marioverehrer",124,10,13)
		print("game by HanamileH",124,17,13)
		print("& soxfox42",124,24,13)
		print("I hope you",124,38,13)
		print("liked the game",124,45,13)

		circ(195,101,33,13)
		circ(195,101,20,0)

		line(207,70 ,213,92 ,0)
		line(225,87 ,213,109,0)
		line(227,110,204,119,0)
		line(216,127,190,121,0)
		line(190,134,177,111,0)
		line(166,117,176,95 ,0)
		line(163,91 ,193,81 ,0)
		line(182,70 ,203,84 ,0)
		--text
		if t%3==0 then
			s_t2[1]=s_t2[1]+1
			if s_t2[1]>#s_t[s_t2[2]] then s_t2[2]=s_t2[2]+1 s_t2[1]=0 end
			if s_t2[2]>#s_t then s_t2[2]=#s_t s_t2[1]=#s_t[#s_t] end
		end

		for i=max(s_t2[2]-17,1),s_t2[2] do
			if i~=s_t2[2] then
				print(s_t[i],3,(i-max(s_t2[2]-15,1))*7+3,13)
			else
				if t%20<10 then
					print(s_t[i]:sub(1,s_t2[1]).."_",3,(i-max(s_t2[2]-17,1))*7+3,13)
				else
					print(s_t[i]:sub(1,s_t2[1]),3,(i-max(s_t2[2]-17,1))*7+3,13)
				end
			end
		end
		line(0,0,240,0,0)
	end
	-------------------------------------------
	--settings
	if not st.sfx then sfx(-1,1,0) sfx(-1,1,1) sfx(-1,1,2) sfx(-1,1,3) end
	if not st.music then music(-1) end
	vbank(1)
	--cursor id
	vbank(0)
	poke4(0x07FF6,cid)
	--fps (2)
	avf[t%60]=t2
	t2 = time() - t1
	fr={0,math.huge,0}
	for i=1,#avf do
		fr[1]=fr[1]+avf[i]
		if avf[i]<fr[2] then fr[2]=avf[i] end
		if avf[i]>fr[3] then fr[3]=avf[i] end
	end
	fr[1]=fr[1]/#avf
end


function BDR(scn_y) scn_y=scn_y-4
	vbank(0)
	if open=="pause" then vbank(1)poke(0x03FF9,0)respal()vbank(0)poke(0x03FF9,0)
		if scn_y==0 or scn_y==63 or scn_y==73 or scn_y==93 or scn_y==133 then
			respal()
			darkpal(max(1-p.t/30,0.4))
			if stt<60 then
				darkpal(stt/60)
			end
		end
		if scn_y==53  then darkpal(p.t1) end
		if scn_y==63  then darkpal(p.t2) end
		if scn_y==83  then darkpal(p.t3) end
		if scn_y==123 then darkpal(p.t4) end
	end

	if open=="pause|accept" then
		if scn_y==0 or scn_y==93 or scn_y==113 then
			respal()
			darkpal(0.2)
			if stt<60 then
				darkpal(stt/60)
			end
		end
		if scn_y==83  then darkpal(p.t1) end
		if scn_y==103 then darkpal(p.t2) end
	end

	if open=="main" then
		if scn_y==0 or scn_y==53 or scn_y==63 or scn_y==83 or scn_y==103 or scn_y==113 or scn_y==133 then
			respal()
			darkpal(min(ms.t/60,0.5))
		end
		if scn_y==43  then darkpal(ms.t1) end
		if scn_y==53  then darkpal(ms.t2) end
		if scn_y==73  then darkpal(ms.t3) end
		if scn_y==93  then darkpal(ms.t4) end
		if scn_y==103 then darkpal(ms.t5) end
		if scn_y==123 then darkpal(ms.t6) end
	end

	if open=="main|newgame" then
		if scn_y==0 or scn_y==93 or scn_y==113 then
			respal()
			darkpal(0.2)
		end
		if scn_y==83 then darkpal(ms.t1) end
		if scn_y==103 then darkpal(ms.t2) end
	end

	if open=="main|skilltest" then
		if scn_y==0 or scn_y==113 or scn_y==133 then
			respal()
			darkpal(0.2)
		end
		if scn_y==103 then darkpal(ms.t1) end
		if scn_y==123 then darkpal(ms.t2) end
	end

	if open=="main|authors" then
		if scn_y==0 or scn_y==123 then
			respal()
			darkpal(0.2)
		end
		if scn_y==113 then
			darkpal(ms.t1)
		end
	end

	if open=="main|settings" or open=="pause|settings" then
		if scn_y==0 or (scn_y-3)%10==0 then
			respal()
			darkpal(0.2)
			if open=="pause|settings" and stt<60 then darkpal(stt/60) end
		end
		if scn_y==23  then darkpal(ms.t1) end
		if scn_y==33  then darkpal(ms.t2) end
		if scn_y==43  then darkpal(ms.t3) end
		if scn_y==53  then darkpal(ms.t4) end
		if scn_y==63  then darkpal(ms.t5) end
		if scn_y==73  then darkpal(ms.t6) end
		if scn_y==83  then darkpal(ms.t7) end
		if scn_y==103 then darkpal(ms.t8) end
		if scn_y==123 then darkpal(ms.t9) end
	end

	if open=="game" then
		vbank(0) poke(0x03FF9,256+R(-1,1)*R(0,F(plr.cd2/2)))
		vbank(1) poke(0x03FF9,256+R(-1,1)*R(0,F(plr.cd2/2)))
	end
end
-- <TILES>
-- 000:4444444443333333434333334333333343333433433333334343334343333333
-- 001:4444444433333333433343333333333334333334333333333333333333333333
-- 002:4444444333333332433343323333333233343232333333323333333233333332
-- 003:6666666665555555656555556555555565555655655555556565556565555555
-- 004:6666666655555555655565555555555556555556555555555555555555555555
-- 005:6666666555555554655565545555555455565454555555545555555455555554
-- 006:555555555f4f4f4f54fff4ff5f4f4f4f5ff4fff45f4f4f4f54fff4ff5f4f4f4f
-- 007:555555554f4f4f4ff4fff4ff4f4f4f4ffff4fff44f4f4f4ff4fff4ff4f4f4f4f
-- 008:555555554f4f4f43f4fff4f34f4f4f43fff4fff34f4f4f43f4fff4f34f4f4f43
-- 009:555555555fffffff5fffffff5fffffff5fffffff5fffffff5fffffff5fffffbf
-- 010:55555555ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 011:55555555fffffff5fffffff5fffffff4fffffff4fffffff4fffffff4fffffff4
-- 012:666666666555555a656555aa65555aa06555aa00655aa00065aa000065aa0000
-- 013:6aaaaaa6aaaaaaaaa000000a0000000000000000000000000000000000000000
-- 014:66666665a5555554aa5565540aa5555400aa5454000aa5540000aa540000aa54
-- 015:0000000000022000002220000003200000022000000220000002300000222200
-- 016:4333333343333333434333334333333343333333433333334343334343333333
-- 017:3433343333333333333333333333333333343333333333333333333333333333
-- 018:3332323233333332333333323333333232333332333323323333333233333332
-- 019:6555555565555555656555556555555565555555655555556565556565555555
-- 020:5655565555555555555555555555555555565555555555555555555555555555
-- 021:5554545455555554555555545555555454555554555545545555555455555554
-- 022:5ff4fff45f4f4f4f54fff4ff5f4f4f4f5ff4fff45f4f4f4f54fff4ff5f4f4f4f
-- 023:fff4fff44f4f4f4ff4fff4ff4f4f4f4ffff4fff44f4f4f4ff4fff4ff4f4f4f4f
-- 024:fff4fff34f4f4f43f4fff4f34f4f4f43fff4fff34f4f4f43f4fff4f34f4f4f43
-- 025:5ffffbcf5fffbcff5fffcfff5fffffff5fffffff5fffffff5fffffff5fffffff
-- 026:fffffffffffffffbffffffbcfffffbcffffffcfffffbffffffbcffffffcfffff
-- 027:fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4fffffff4
-- 028:65aa00006aa000006aa000006aa00000aa000000aa000000aa000000aa000000
-- 030:0000aa5400000aa400000aa400000aa4000000aa000000aa000000aa000000aa
-- 031:0000000000056000005006000000050000005000000500000050000000556500
-- 032:4333333343333333434333334333333343333333433333334333433343333333
-- 033:3433333333333233433333333333333333333233333333333323333333333333
-- 034:3332333233333332333333323333333232333232333333323333333233333332
-- 035:6555555565555555656555556555555565555555655555556555655565555555
-- 036:5655555555555455655555555555555555555455555555555545555555555555
-- 037:5554555455555554555555545555555454555454555555545555555455555554
-- 038:5ff4fff45f4f4f4f54fff4ff5f4f4f4f5ff4fff45f4f4f4f54fff4ff5f4f4f4f
-- 039:fff4fff44f4f4f4ff4fff4ff4f4f4f4ffff4fff44f4f4f4ff4fff4ff4f4f4f4f
-- 040:fff4fff34f4f4f43f4fff4f34f4f4f43fff4fff34f4f4f43f4fff4f34f4f4f43
-- 041:5fffffff5fffffff5fffffff5fffffff5fffffff5ffffffb5fffffbc5fffffcf
-- 042:fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb
-- 043:fffffff4fffffff4fffffff4fffffff4fffffff4fbfffff4bcfffff4cffffff4
-- 044:aa000000aa000000aa000000aa0000006aa000006aa000006aa0000065aa0000
-- 046:000000aa000000aa000000aa000000aa00000aa400000aa400000aa40000aa54
-- 047:0000000000043000004003000000040000004000000004000030030000043000
-- 048:4333333343333333433333334333333343343333433333334333333332222222
-- 049:3333333333333332233323333333333333333332333333333333333322222222
-- 050:3332333233333332333333323333333233233232333333323333333222222222
-- 051:6555555565555555655555556555555565565555655555556555555554444444
-- 052:5555555555555554455545555555555555555554555555555555555544444444
-- 053:5554555455555554555555545555555455455454555555545555555444444444
-- 054:5ff4fff45f4f4f4f54fff4ff5f4f4f4f5ff4fff45f4f4f4f54fff4ff33333333
-- 055:fff4fff44f4f4f4ff4fff4ff4f4f4f4ffff4fff44f4f4f4ff4fff4ff33333333
-- 056:fff4fff34f4f4f43f4fff4f34f4f4f43fff4fff34f4f4f43f4fff4f333333333
-- 057:5fffffff5fffffff5fffffff5fffffff5fffffff5fffffff5555555554444444
-- 058:fffffffcffffffffffffffffffffffffffffffffffffffff5554444444444444
-- 059:fffffff4fffffff4fffffff4fffffff4fffffff4fffffff44444444444444444
-- 060:65aa000065aa0000655aa0006555aa0065565aa0655555aa6555555a54444444
-- 061:0000000000000000000000000000000000000000a000000aaaaaaaaa4aaaaaa4
-- 062:0000aa540000aa54000aa55400aa55540aa55454aa555554a555555444444444
-- 063:0000000000c0070000b00b0000c00c00007bcc000000070000000b0000000c00
-- 064:666666666555555d656555dd65555dd06555dd00655dd00065dd000065dd0000
-- 065:6dddddd6ddddddddd000000d0000000000000000000000000000000000000000
-- 066:66666665d5555554dd5565540dd5555400dd5454000dd5540000dd540000dd54
-- 067:ffffffffffaaaffffffffffffffffffffffffffffffffffaffffffffffffffff
-- 068:fffffffffffffffffffffffbffffffffffffffffaafffffffffffffffffffffa
-- 069:ffffffffffffffffbbffffffffffffffffffffffffffffffffffffffaaffffff
-- 070:6666666665555555656555556555555565555655655555556565556565555555
-- 071:6666666655555555655565555555555556555556555555555555555555555555
-- 072:6666666555555554655565545555555455565454555555545555555455555554
-- 073:4444444443333333434333334333333343333433433333334343334343333333
-- 074:4444444433333333433343333333333334333334333333333333333333333333
-- 075:4444444333333332433343323333333233343232333333323333333233333332
-- 076:6666666665671111656777776567711165671111656711776567117765671177
-- 077:6666666611111111777777771177771111177111711771177117711771177117
-- 078:6666666511117654777776541117765411117654771176547711765477117654
-- 079:0000000000aaba0000a0000000b0000000aaa00000000b0000a00a00000aa000
-- 080:65dd00006dd000006dd000006dd00000dd000000dd000000dd000000dd000000
-- 082:0000dd5400000dd400000dd400000dd4000000dd000000dd000000dd000000dd
-- 083:ffffbbbfffffffffffffffffffffffffffffffffffffffffffffffffffaaafff
-- 084:fffffffffffffffffbbbfffffffffffffffffffffffffffabbbfffffffffffff
-- 085:ffffffffffffffffffffffffffffffffffffffffaaffffffffffffffffffffff
-- 086:6555555565555555656555556555555565555555655555556565556565555555
-- 087:5655565555555555555555555555555555565555555555555555555555555555
-- 088:5554545455555554555555545555555454555554555545545555555455555554
-- 089:4333333343333333434333334333333343333333433333334343334343333333
-- 090:3433343333333333333333333333333333343333333333333333333333333333
-- 091:3332323233333332333333323333333232333332333323323333333233333332
-- 092:6567117765671177656711776567117765671111656771116567777765671111
-- 093:7117711171177711711777777117711711177111117777117777777711111111
-- 094:1111765411117654771176547711765411117654111776547777765411117654
-- 095:00000000000ded0000d0000000d0000000edd00000d00d0000d00d00000ed000
-- 096:dd000000dd000000dd000000dd0000006dd000006dd000006dd0000065dd0000
-- 098:000000dd000000dd000000dd000000dd00000dd400000dd400000dd40000dd54
-- 099:fffffffffffffffffffffffffffbbbffffffffffffffffffffffffffffffffaa
-- 100:fffffffffffffffffffaaafffffffffffffffffbffffffffffffffffafffffff
-- 101:ffffffffffffffffffffffffffffffffbbffffffffffffffffffffffffffffff
-- 102:6555555565555555656555556555555565555555655555556555655565555555
-- 103:5655555555555455655555555555555555555455555555555545555555555555
-- 104:5554555455555554555555545555555454555454555555545555555455555554
-- 105:4333333343333333434333334333333343333333433333334333433343333333
-- 106:3433333333333233433333333333333333333233333333333323333333333333
-- 107:3332333233333332333333323333333232333232333333323333333233333332
-- 108:6567777765671717656717176567777765677117656771176567777765677117
-- 109:7777777717177777171777777777777711733711117337117777777733733733
-- 110:7777765477777654777776547777765473377654733776547777765471177654
-- 111:0000000000cbcc0000000b0000000c000000c0000000b000000b0000000c0000
-- 112:65dd000065dd0000655dd0006555dd0065565dd0655555dd6555555d54444444
-- 113:0000000000000000000000000000000000000000d000000ddddddddd4dddddd4
-- 114:0000dd540000dd54000dd55400dd55540dd55454dd555554d555555444444444
-- 115:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 116:ffffffffffffffffffffffaafffffffffbbbffffffffffffffffffffffffffff
-- 117:ffffffffffffffffaffffffffffffffffffffffffbbbffffffffffffffffffff
-- 118:6555555565555555655555556555555565565555622222222311111152322222
-- 119:5555555555555554455545555555555555555554222ed2221111111122222222
-- 120:5554555455555554555555545555555455455454222222241111112322222234
-- 121:4333333343333333433333334333333343343333422222222311111132322222
-- 122:3333333333333332233323333333333333333332222ed2221111111122222222
-- 123:3332333233333332333333323333333233233232222222221111111322222232
-- 124:6567711765677777656666666555555565565555655556556555555554444444
-- 125:3373373377777777666666665555555555555554555545556555555544444444
-- 126:7117765477777654666666545555555455455454455555545555555444444444
-- 127:0000000000056000005006000050050000055000005005000050050000056000
-- 128:6666666665555555656555556555555565555655655555556565556565555555
-- 129:666666665555555565556555555555555655555655555552555555225555522f
-- 130:666666655555555465552222552222222222ffff22ffffffffffffffffffffff
-- 131:66666666655555552222555522222255ffff2222ffffff22ffffffffffffffff
-- 132:66666666555555556555655555555555565555562555555522555555f2255555
-- 133:6666666555555554655565545555555455565454555555545555555455555554
-- 134:6666666665555555656555556555555565555655655555556565556565555555
-- 135:6666666655555555655565555555555556555556555555525555552255555227
-- 136:6666666555555554655522225522222222227776227777767777777677777776
-- 137:6666666665555555222255552222225577772222777777227777777777777777
-- 138:6666666655555555655565555555555556555556255555552255555572255555
-- 139:6666666555555554655565545555555455565454555555545555555455555554
-- 140:ffffffffff888ffffffffffffffffffffffffffffffffff8ffffffffffffffff
-- 141:fffffffffffffffffffffff9ffffffffffffffff88fffffffffffffffffffff8
-- 142:ffffffffffffffff99ffffffffffffffffffffffffffffffffffffff88ffffff
-- 143:0000000000043000004003000030040000034300000004000030030000043000
-- 144:6555555565555555656555556555555565555555655555556565556565555555
-- 145:565522ff55522fff55222fff5522ffff522fffff522fffff22ffffff22ffffff
-- 146:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 147:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 148:ff225655fff22555fff22255ffff2255fffff225fffff225ffffff22ffffff22
-- 149:5554545455555554555555545555555454555554555545545555555455555554
-- 150:6555555565555555656555556555555565555555655555556565556565555555
-- 151:5655227755522777552227775522777752277777522777772277777722777777
-- 152:7777777677777776777777767777777677777776777777767777777677777776
-- 153:7777777777777777aaaaaaaaaaaabbbaaaabbbbbaabbbbbbaabbbbbbaabbbbbb
-- 154:7722565577722555aaaa2255aaaa2255aaaaa225baaaa225baaaaa22baaaaa22
-- 155:5554545455555554555555545555555454555554555545545555555455555554
-- 156:ffff999fffffffffffffffffffffffffffffffffffffffffffffffffff888fff
-- 157:fffffffffffffffff999fffffffffffffffffffffffffff8999fffffffffffff
-- 158:ffffffffffffffffffffffffffffffffffffffff88ffffffffffffffffffffff
-- 159:7777777777177111711771717717717177177171711171117777777777777777
-- 160:6555555565555555656555556555555265555552655555526555655265555552
-- 161:22ffffff22ffffff22ffffff2fffffff2fffffff2fffffff2fffffff2fffffff
-- 162:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 163:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 164:ffffff22ffffff22ffffff22fffffff2fffffff2fffffff2fffffff2fffffff2
-- 165:5554555455555554555555542555555424555454255555542555555425555554
-- 166:6555555565555555656555556555555265555552655555526555655265555552
-- 167:2277777722777777227777772777777727777777277777772777777727777777
-- 168:7777777677777766777776767777677677776776777767767777767677777766
-- 169:baabbbbbbbaabbbabbbaaaaabbbbaaaabbbbbaaabbbbbaaabbabbbaabaaabbbb
-- 170:aaaaaa22aaaaaa22aaaaaa22aaaaaaa2aaaaaaa2aaaaaaa2aaaaaaa2baaaaaa2
-- 171:5554555455555554555555542555555424555454255555542555555425555554
-- 172:fffffffffffffffffffffffffff999ffffffffffffffffffffffffffffffff88
-- 173:fffffffffffffffffff888fffffffffffffffff9ffffffffffffffff8fffffff
-- 174:ffffffffffffffffffffffffffffffff99ffffffffffffffffffffffffffffff
-- 176:6555555265555552655555526555555265565555655555556555555554444444
-- 177:2fffffff2fffffff2fffffff2fffffff22ffffff22ffffff22ffffff422fffff
-- 178:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 179:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 180:fffffff2fffffff2fffffff2fffffff2ffffff22ffffff22ffffff22fffff224
-- 181:2554555425555554255555542555555455455454555555545555555444444444
-- 182:6555555265555552655555526555555265565555655555556555555554444444
-- 183:2777777727777777277777772777777722777777227777772277777742277777
-- 184:7777777677777776777777767777777677777776777777767777777677777776
-- 185:bbaaabbbbbbaaaaaabbbaaaaaabbbaaaabbbaaaabbbaaaaabbaaaaaabaaaaaaa
-- 186:baaaaaa2aaaaaaa2aaaaaaa2aaaaaaa2aaaaaa22aaaaaa22aaaaaa22aaaaa224
-- 187:2554555425555554255555542555555455455454555555545555555444444444
-- 188:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 189:ffffffffffffffffffffff88fffffffff999ffffffffffffffffffffffffffff
-- 190:ffffffffffffffff8ffffffffffffffffffffffff999ffffffffffffffffffff
-- 192:555555555ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa5ccccccc
-- 193:55555555ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaacccccccc
-- 194:55555555ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaacccccccc
-- 195:55555555ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaacccccccc
-- 196:55555555ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaacccccccc
-- 197:55555555ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4ccccccc4
-- 198:1b1333331b1322221b1322221b1322221b1322221b1322221b1322221b132222
-- 199:3333333322222222222222222222222222222222222222222222222222222222
-- 200:333331b1222231b1222231b1222231b1222231b1222231b1222231b1222231b1
-- 201:1b1111111b1111111333333313ffffff13ffffff13ffffff13ffffff13ffffff
-- 202:111111111111111133333333ffffffffffffffffffffffffffffffffffffffff
-- 203:111111b1111111b133333331ffffff31ffffff31ffffff31ffffff31ffffff31
-- 204:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 205:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 206:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 208:5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa
-- 209:bbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaa
-- 210:bbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaa
-- 211:bbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaa
-- 212:bbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaa
-- 213:bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4
-- 214:1b1322221b1322221b1322221b1322221b1322221b1322221b1322221b132222
-- 215:2222222222222222222222222222222222222222222222222222222222222222
-- 216:222231b1222231b1222231b1222231b1222231b1222231b1222231b1222231b1
-- 217:13ffffff13ffffff13ffffff13ffffff13ffffff13ffffff13ffffff13ffffff
-- 218:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 219:ffffff31ffffff31ffffff31ffffff31ffffff31ffffff31ffffff31ffffff31
-- 220:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 221:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 222:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 224:5ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb
-- 225:ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb
-- 226:ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb
-- 227:ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb
-- 228:ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb
-- 229:ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4
-- 230:1b1322221b1322221b1322221b1333331b11111122222222222222221b111111
-- 231:2222222222222222222222223333333311111111222222222222222211111111
-- 232:222231b1222231b1222231b1333331b1111111b12222222222222222111111b1
-- 233:13ffffff13ffffff13ffffff13ffffff13ffffff23ffffff23ffffff13ffffff
-- 234:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 235:ffffff31ffffff31ffffff31ffffff31ffffff31ffffff32ffffff32ffffff31
-- 236:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 237:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 238:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 240:5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5555555554444444
-- 241:aaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb5555555544444444
-- 242:aaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb5555555544444444
-- 243:aaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb4444444444444444
-- 244:aaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb4444444444444444
-- 245:aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb44444444444444444
-- 246:1b1111111b1111111b1111111b1111111b1111111b1111111b1111111b111111
-- 247:1111111111111111111111111111111111111111111111111111111111111111
-- 248:111111b1111111b1111111b1111111b1111111b1111111b1111111b1111111b1
-- 249:13ffffff13ffffff13ffffff13ffffff13ffffff13ffffff13ffffff13ffffff
-- 250:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 251:ffffff31ffffff31ffffff31ffffff31ffffff31ffffff31ffffff31ffffff31
-- 252:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 253:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 254:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- </TILES>

-- <TILES1>
-- 114:0000000000000000000000000000000000000044000044440044444444444444
-- 115:0000004400004444004444444444444444444444444444444444444444444444
-- 116:4400000044440000444444004444444444444444444444444444444444444444
-- 117:0000000000000000000000000000000044000000444400004444440044444444
-- 128:0000000000000000000000000000000000000044000004440000004400000000
-- 129:0000004400004444004444444444444444444444444444444444444444444444
-- 130:4444444444444444444444444444444444444400444400004400000000000000
-- 131:4444440044440000440000000000000000000000000000000000000000000000
-- 132:0044444400004444000000440000000000000000000000000000000000000000
-- 133:4444444444444444444444444444444400444444000044440000004400000000
-- 134:4400000044440000444444004444444444444444444444444444444444444444
-- 135:0000000000000000000000000000000044000000444400004444440044444444
-- 144:4400000044440000444444004444444444444444444444444444444444444444
-- 145:0044440000000000000000000000000044000000444400004444440044444444
-- 150:0044444400004444000000440000000000000000000000000000000000000000
-- 151:4444444444444444444444444444444444444444444444444444444444444444
-- 160:4444444444444444444444444444444444444444444444444444444444444444
-- 161:4444444444444444444444444444444444444444444444444444444444444444
-- 162:4400000044440000444444004444444444444444444444444444444444444444
-- 163:0000000000000000000000000000000044000000444400004444440044444444
-- 167:4444444444444444444444444444444444444444444444444444444444444444
-- 176:4444444444444444444444444444444444444444444444444444444444444444
-- 177:4444444444444444444444444444444444444444444444444444444444444444
-- 178:4444444444444444444444444444444444444444444444444444444444444444
-- 179:4444444444444444444444444444444444444444444444444444444444444444
-- 183:4444444444444444444444444444444444444444444444444444444444444444
-- 192:4444444444444444444444444444444444444444444444444444444444444444
-- 193:4444444444444444444444444444444444444444444444444444444444444444
-- 194:4444444444444444444444444444444444444444444444444444444444444444
-- 195:4444444444444444444444444444444444444444444444444444444444444444
-- 199:4444444444444444444444444444444444444444444444444444444444444444
-- 208:4444444444444444444444444444444444444444444444444444444444444444
-- 209:4444444444444444444444444444444444444444444444444444444444444444
-- 210:4444444444444444444444444444444444444444444444444444444444444444
-- 211:4444444444444444444444444444444444444444444444444444444444444444
-- 214:0000000000000000000000000000000000000000000000440000444400444444
-- 215:4444444444444444444444444444444444444444444444444444444444444444
-- 224:4444444400444444000044440000004400000000000000000000000000000000
-- 225:4444444444444444444444444444444444444444004444440000444400000044
-- 226:4444444444444444444444444444444444444444444444444444444444444444
-- 227:4444444444444444444444444444444444444444444444444444444444444444
-- 228:0000000000000000000000000000000000000000000000440000444400044444
-- 229:0000000000000044000044440044444444444444444444444444444444444444
-- 230:4444444444444444444444444444444444444444444444004444000044000000
-- 231:4444444444444400444400004400000000000000000000000000000000000000
-- 242:4444444400444444000044440000004400000000000000000000000000000000
-- 243:4444444444444444444444444444444444444444004444440000444400000044
-- 244:0004444400044444000444440004444400044444000444000004000000000000
-- 245:4444444444444400444400004400000000000000000000000000000000000000
-- </TILES1>

-- <SPRITES>
-- 000:0000000000000000000000000000000000777777007777770077711100777000
-- 001:0000000000000000000000000000000077770000777770001177770000177700
-- 002:0000000000000000000000000000000000777777077777777777111177710000
-- 003:0000000000000000000000000000000077000077777000777777007717770077
-- 004:0000000000000000000000000000000077777777777777777711117777000017
-- 005:0000000000000000000000000000000000007777700077777700111177000000
-- 006:0000000000000000000000000000000077777777777777777777111177770000
-- 007:0000000000000000000000000000000000007777000777770077777100777710
-- 008:0000000000000000000000000000000077770000777770001777770001777700
-- 009:0000000000000000000000000000000077770000777700007777000077770000
-- 011:0aa000000aa0000b0aa000bb0aa00bbb0aa00bbb0aa00bbb0aab00bb0aabb00b
-- 012:00000000bb000000bbb00000bbbb0000bbbb0000bbbb0000bbb00000bb000000
-- 013:00ff00ff00ff00ffff00ff00ff00ff0000ff00ff00ff00ffff00ff00ff00ff00
-- 014:00ff00ff00ff00ffff00ff00ff00ff0000ff00ff00ff00ffff00ff00ff00ff00
-- 015:999997b7988897b7988897b7988897b7999997e7222227e7222227e7222227e7
-- 016:0077700000767000006760000076767600676767006661110066600000666000
-- 017:0007770000067600006767007676710067671000111100000000000000000000
-- 018:7770000067600000767000006760000076700000666000006660000066660000
-- 019:0777007706760067076700760676006707670076066600660666006666660066
-- 020:7700000767000007760000766767676776767676661111666600006666000016
-- 021:7700000067000000760000006100000010000000600000006000000066000000
-- 022:7777000067670000767600006767000076760000666600006666000066660000
-- 023:0077770000676700007676000067676700767676006666110066660000666600
-- 024:0077770000676700007676006767670076767600116666000066660000666600
-- 025:7777000067670000767600006767000076760000666600006666000066660000
-- 027:0aabbb000aabbbb00aabbbbb0aabbbbb0aabbbbb0aabb0bb0aab000b0aabb000
-- 028:0000000000000000000000000000000000000000b0000000bb000000bbbbb000
-- 029:00ff00ff00ff00ffff00ff00ff00ff0000ff00ff00ff00ffff00ff00ff00ff00
-- 030:00ff00ff00ff00ffff00ff00ff00ff0000ff00ff00ff00ffff00ff00ff00ff00
-- 031:8822777788227777ffff7777f711711771ff77771fff77771fff77771fffffff
-- 032:0066600000666000001110000000000000000000000000000000000000000000
-- 034:1666666601666666001111110000000000000000000000000000000000000000
-- 035:6661006666100066110000110000000000000000000000000000000000000000
-- 036:6600000666000006110000010000000000000000000000000000000000000000
-- 037:6600000066000000110000000000000000000000000000000000000000000000
-- 038:6666000066660000111100000000000000000000000000000000000000000000
-- 039:0066660000666600001111000000000000000000000000000000000000000000
-- 040:0066660000666600001111000000000000000000000000000000000000000000
-- 041:6666666666666666111111110000000000000000000000000000000000000000
-- 042:6666000066660000111100000000000000000000000000000000000000000000
-- 043:0aabbb000aa0bbb00aa00bbb0aa0bbb00aabbb000aabb0000aab00000aa00000
-- 044:0bbbb00000000000000000000000000000000000000000000000000000000000
-- 045:00ff00ff00ff00ffff00ff00ff00ff0000ff00ff00ff00ffff00ff0000000000
-- 046:00ff00ff00ff00ffff00ff00ff00ff0000ff00ff00ff00ffff00ff0000000000
-- 047:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 048:4444444343333332433433324333323243433332433323324333333232222222
-- 049:4444444343333332433433324333323243433332433323324333333232222222
-- 050:4444444343333332433433324333323243433332433323324333333232222222
-- 051:7777777676666665766766657666656576766665766656657666666565555555
-- 052:7777777676666665766766657666656576766665766656657666666565555555
-- 053:7777777676666665766766657666656576766665766656657666666565555555
-- 054:555555555f4f4f4f54fff4ff5f4f4f4f5ff4fff45f4f4f4f54fff4ff5f4f4f4f
-- 055:555555554f4f4f4ff4fff4ff4f4f4f4ffff4fff44f4f4f4ff4fff4ff4f4f4f4f
-- 056:555555554f4f4f43f4fff4f34f4f4f43fff4fff34f4f4f43f4fff4f34f4f4f43
-- 057:555555555fffffff5fffffff5fffffff5fffffff5fffffff5fffffbf5ffffbcf
-- 058:55555555ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 059:55555555fffffff5fffffff5fffffff4fffffff4fffffff4ffbffff4fbcffff4
-- 060:ffffffffff888ffffffffffffffffffffffffffffffffff8ffffffffffffffff
-- 061:fffffffffffffffffffffff9ffffffffffffffff88fffffffffffffffffffff8
-- 062:ffffffffffffffff99ffffffffffffffffffffffffffffffffffffff88ffffff
-- 063:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 064:4444444343333332433433324333323243433332433323324333333232222222
-- 065:4444444343333332433433324333323243433332433323324333333232222222
-- 066:4444444343333332433433324333323243433332433323324333333232222222
-- 067:7777777676666665766766657666656576766665766656657666666565555555
-- 068:7777777676666665766766657666656576766665766656657666666565555555
-- 069:7777777676666665766766657666656576766665766656657666666565555555
-- 070:5ff4fff45f4f4f4f54fff4ff5f4f4f4f5ff4fff45f4f4f4f54fff4ff5f4f4f4f
-- 071:fff4fff44f4f4f4ff4fff4ff4f4f4f4ffff4fff44f4f4f4ff4fff4ff4f4f4f4f
-- 072:fff4fff34f4f4f43f4fff4f34f4f4f43fff4fff34f4f4f43f4fff4f34f4f4f43
-- 073:5fffbcff5fffcfff5fffffff5fffffff5fffffff5fffffff5fffffff5fffffff
-- 074:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffffff
-- 075:bcfffff4cffffff4fffffff4fffffff4fffffff4fffffff4fffffff4ffbffff4
-- 076:ffff999fffffffffffffffffffffffffffffffffffffffffffffffffff888fff
-- 077:fffffffffffffffff999fffffffffffffffffffffffffff8999fffffffffffff
-- 078:ffffffffffffffffffffffffffffffffffffffff88ffffffffffffffffffffff
-- 079:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 080:4444444343333332433433324333323243433332433323324333333232222222
-- 081:4444444343333332433433324333323243433332433323324333333232222222
-- 082:4444444343333332433433324333323243433332433323324333333232222222
-- 083:7777777676666665766766657666656576766665766656657666666565555555
-- 084:7777777676666665766766657666656576766665766656657666666565555555
-- 085:7777777676666665766766657666656576766665766656657666666565555555
-- 086:5ff4fff45f4f4f4f54fff4ff5f4f4f4f5ff4fff45f4f4f4f54fff4ff53333333
-- 087:fff4fff44f4f4f4ff4fff4ff4f4f4f4ffff4fff44f4f4f4ff4fff4ff33333333
-- 088:fff4fff34f4f4f43f4fff4f34f4f4f43fff4fff34f4f4f43f4fff4f333333333
-- 089:5ffffffb5ffffffc5fffffff5fffffff5fffffff5fffffff5fffffff54444444
-- 090:cffffffffffffffffffffffbfffffffcffffffffffffffffffffffff44444444
-- 091:fbcffff4bcfffff4cffffff4fffffff4fffffff4fffffff4fffffff444444444
-- 092:fffffffffffffffffffffffffff999ffffffffffffffffffffffffffffffff88
-- 093:fffffffffffffffffff888fffffffffffffffff9ffffffffffffffff8fffffff
-- 094:ffffffffffffffffffffffffffffffff99ffffffffffffffffffffffffffffff
-- 095:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 096:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 097:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 098:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 099:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 100:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 101:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 102:4444444343333332433433324333323243433332433323324333333232222222
-- 103:4444444343333332431111124122122112221222122212221232123212221222
-- 104:4444444343333332433433324333323213433332133323321333333212222222
-- 105:7777777676666665766766657666656576766665766656657666666565555555
-- 106:7777777676666665761111157122122112221222122212221232123212221222
-- 107:7777777676666665766766657666656516766665166656651666666515555555
-- 108:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 109:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 110:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 111:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 112:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 113:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 114:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 115:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 116:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 117:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 118:4444444343333332433433324333323243433332433323324333333232222222
-- 119:122212221222122212221222122212221232123212221222122ba222111aa111
-- 120:1444444313333332133433321333323213433332133323321333333212222222
-- 121:7777777676666665766766657666656576766665766656657666666565555555
-- 122:122212221222122212221222122212221232123212221222122ba222111aa111
-- 123:1777777616666665166766651666656516766665166656651666666515555555
-- 124:7777777676666555766557777657777576577558757758887577588865758888
-- 125:5555555576eeee67755555575888988588889888888898888888988888889888
-- 126:7777777655566665777556655777756585577565888577558885775588885755
-- 127:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 128:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 129:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 130:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 131:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 132:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 133:0000ffff0000ffff0000ffff0000ffffffff0000ffff0000ffff0000ffff0000
-- 134:4444444343333332433433324333323243433332433323324333333232222222
-- 135:1222222212223222123222321222222212211222412112214311111232222222
-- 136:1444444313333332133433321333323213433332433323324333333232222222
-- 137:7777777676666665766766657666656576766665766656657666666565555555
-- 138:1222222212223222123222321222222212211222712112217611111565555555
-- 139:1777777616666665166766651666656516766665766656657666666565555555
-- 140:5775888857588888575888885759999957588888575888885758888857758888
-- 141:8899998889888898988888899888888998888889988888898988889888999988
-- 142:8888577588888575888885758888857599999575888885758888857588885775
-- 143:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 144:fffffffffffffffffffffffffffffffcffffffccfffffcccffffccccffffcccc
-- 145:fffffffffffffffffccccccfcccccccccccccccccccccccccccccccccccccccc
-- 146:ffffffffffffffffffffffffcfffffffccffffffcccfffffccccffffccccffff
-- 147:fffffffffffffffffffffffffffffffeffffffeefffffeeeffffeeeeffffeeee
-- 148:fffffffffffffffffeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 149:ffffffffffffffffffffffffefffffffeeffffffeeefffffeeeeffffeeeeffff
-- 150:aaaaaaaaa0000000a0000000a0000000a0000000a0000000a0000000a0000000
-- 151:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 152:aaaaaa00000000d0000000d0000000d0000000d0000000d0000000d0000000d0
-- 156:7575888875775888757758887657755876577775766557777666655565555555
-- 157:88898888888988888889888888898888588988857555555776eeee6755555555
-- 158:8888575688857755888577558557756557777565777556655556666565555555
-- 159:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 160:ffffccccfffcccccfffcccccfffcccccffccccccffccccccffccccccffcccccc
-- 161:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 162:ccccffffcccccfffcccccfffcccccfffccccccffccccccffccccccffccccccff
-- 163:ffffeeeefffeeeeefffeeeeefffeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeee
-- 164:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 165:eeeeffffeeeeefffeeeeefffeeeeefffeeeeeeffeeeeeeffeeeeeeffeeeeeeff
-- 166:a0000000a0000000a0000000a0000000a0000000a0000000a0000000a0000000
-- 168:000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000d0
-- 169:5555555556666665566666655666666556666665566666545666654455555444
-- 170:4555555445666654456666544566665444555544444444444444444444444444
-- 171:5555555556666665566666655666666556666665456666654456666544455555
-- 172:2222222223333333233333332332222223321111233211112332111123321111
-- 173:2222222233333333333333332222222211111111111111111111111111111111
-- 174:2222222233333332333333322222233211112332111123321111233211112332
-- 175:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 176:ffccccccffccccccffccccccffccccccfffcccccfffcccccfffcccccffffcccc
-- 177:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 178:ccccccffccccccffccccccffccccccffcccccfffcccccfffcccccfffccccffff
-- 179:ffeeeeeeffeeeeeeffeeeeeeffeeeeeefffeeeeefffeeeeefffeeeeeffffeeee
-- 180:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 181:eeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeefffeeeeefffeeeeefffeeeeffff
-- 182:a0000000a0000000a0000000a0000000a0000000a0000000a0000000a0000000
-- 184:000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000d0
-- 185:4444444455554444566654495666544956665449566654445555444444444444
-- 186:4994499498899889887888888788888888888888988888894988889444988944
-- 187:4444444444445555944566659445666594456665444566654444555544444444
-- 188:2332111123321111233211112332111123321111233211112332111123321111
-- 189:1111111111111111111111111111111111111111111111111111111111111111
-- 190:1111233211112332111123321111233211112332111123321111233211112332
-- 191:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 192:ffffccccffffccccfffffcccffffffccfffffffcffffffffffffffffffffffff
-- 193:ccccccccccccccccccccccccccccccccccccccccfccccccfffffffffffffffff
-- 194:ccccffffccccffffcccfffffccffffffcfffffffffffffffffffffffffffffff
-- 195:ffffeeeeffffeeeefffffeeeffffffeefffffffeffffffffffffffffffffffff
-- 196:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeefffffffffffffffff
-- 197:eeeeffffeeeeffffeeefffffeeffffffefffffffffffffffffffffffffffffff
-- 198:a0000000a0000000a0000000a0000000a0000000a00000000ddddddd00000000
-- 199:000000000000000000000000000000000000000000000000dddddddd00000000
-- 200:000000d0000000d0000000d0000000d0000000d0000000d0ddddddd000000000
-- 201:5555544456666544566666545666666556666665566666655666666555555555
-- 202:4449944444444444444444444455554445666654456666544566665445555554
-- 203:4445555544566665456666655666666556666665566666655666666555555555
-- 204:2332111123321111233211112332111123322222233333332333333322222222
-- 205:1111111111111111111111111111111122222222333333333333333322222222
-- 206:1111233211112332111123321111233222222332333333323333333222222222
-- 207:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 208:ffffffffaaaaaaaafcfcfcfcbfbfbfbffcfcfcfcbfbfbfbffcfcfcfcbfbfbfbf
-- 209:ffffffffaaaaaaaafcfcfcfcbfbfbfbffcfcfcfcbfbfbfbffcfcfcfcbfbfbfbf
-- 210:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 211:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 212:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 213:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 214:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 215:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 216:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 217:5555555556666665566666655666666556666665566666545666654455555444
-- 218:4555555445666654456666544566665444555544444444444444444444aaaa44
-- 219:5555555556666665566666655666666556666665456666654456666544455555
-- 220:2222222223333333234343432333333324343434233333332343434322222222
-- 221:2222222233333333434343433333333334343434333333334343434322222222
-- 222:2222222233333332434343423333333234343432333333324343434222222222
-- 223:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 224:fcfcfcfcbfbfbfbffcfcfcfcbfbfbfbffcfcfcfcbfbfbfbfaaaaaaaaffffffff
-- 225:fcfcfcfcbfbfbfbffcfcfcfcbfbfbfbffcfcfcfcbfbfbfbfaaaaaaaaffffffff
-- 226:000000000000000000000000000000000000000000000000dddddddd00000000
-- 227:00000000000000000000000000000000000000000000000000000000a0000000
-- 233:44444444555544445666544a5666544a5666544a5666544a5555444444444444
-- 234:aabbbbaaabbbbbbabbbaabbbbba44abbbba44abbbbbaabbbabbbbbbaaabbbbaa
-- 235:4444444444445555a4456665a4456665a4456665a44566654444555544444444
-- 236:7fffffff7fffffff7ffffcff7fffcfff7ffcffff7fffffff7fffffff7ffffffc
-- 237:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfff
-- 238:fffffffcfffffffcfffffffcfffffffcfffcfffcffcffffcfffffffcfffffffc
-- 239:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 240:bb1b1111b11b111111111111bb11111111111111111111111111111111111111
-- 241:11111111111111111111111111111dd111111111111d11d1111d1dd111111111
-- 242:1113111111131111111111113311133111111111111311111113111111111111
-- 243:001122330011223344556677445566778899aabb8899aabbccddeeffccddeeff
-- 244:000000000000000000000000000000000000000000000000dddddddd00000000
-- 245:000000000000000000000000000000000000000000000000dddddddd00000000
-- 246:000000000000000000000000000000000000000000000000dddddddd00000000
-- 247:000000000000000000000000000000000000000000000000dddddddd00000000
-- 248:000000000000000000000000000000000000000000000000dddddddd00000000
-- 249:5555544456666544566666545666666556666665566666655666666555555555
-- 250:44aaaa4444444444444444444455554445666654456666544566665445555554
-- 251:4445555544566665456666655666666556666665566666655666666555555555
-- 252:7fffffcf7ffffcff7fffcfff7fffffff22222222233333332333333322222222
-- 253:fffcffffffcfffffffffffffffffffff2222222234bbbb4334bccb4322222222
-- 254:fffffffcfffffffcfffffffcfffffffc22222222333333323333333222222222
-- 255:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d00dddddd000000000
-- </SPRITES>

-- <MAP>
-- 068:0100000000000001000100000100000000000000000000000000000f81f1f1f1f0ef81f0efeeef181f1fe00ee0000000ed0fef00eee00feeeee0000000fe0feefe10e1000f0000000000113200ed2e2100000000000000000000eed9edede01111111111111111111111111111111100ee9d9deeeedededd1010110100101010110001000010100000000000000001000000000018e0ef18ef1f181f1fefeeff81e0ff00e10000000dd0ee000dee0eeeeeef0000000ef0ee0e01e10000f0000000e00112000de12100000000000000010000d9e9ed9de111211212112112111f211111f111f11000eddedeed9eeddddd
-- 069:f111011010110110100010101101001000000000010010000000000081fef1f181f1ff8f1feef1f1f1f00e00ee00000000def2f00ee1f0eeeeee0000000ee0eefee0110000e0000004420131000e2e2100000000000000010000e9dd9dee11111211111112f11121102112112111200fdde1edeeddeefefe1111111111101101111101101010110101010101001000000000000018f1ffe8fe0f11feefee1f01fe100e00ee00000000dd0ee00edee01edef1f000f0ffeffee021e1100010000003330e32000f2e2100000000000000010000ddd9edee1112111211211112121111110111f111100eeeeefed919ddddd9
-- 070:212121212121121120111111111110101010001000100010000000000fefeefe81f1ff818e1f181f0ef00ef0ee100000000ddee000eee0ffeeeee000000fee0eef2f1110000e00f0034302320000e2e20000000000000010000fe99dedee12111011211212111111211211211111100edeeedeeeded9d9ed222222222222212212222121011f111101101010100010101001010101f1f1f1fefe0efefefefe0fe1000fe0fde00000000edeee00eeee0eedeeef000f81f2feeeee1110000e00f0033402330000ee2e0000000000000000000fddededdf1f121211121111212111111111112f121001eede9dede9d9ded9
-- 071:22222222222222222222222222221212121111f1111101010101001000efef1818181f181ee1f1f1fef000d00ee100000000ddee000dee1feee1ee00f00efee0ee020111000ef0000234023300000eee0000000000000000000ededdeed0211111121121211f1121212112011111100e1eee1dde9d9ddded2223233333333333335322222222222212121211f1f1110110101101001f1efef1ff1f81fef1ffefe00000ef0e210f00002f0ddee00fdee0eedefef00018fee0def211e10000e0000243123300f001210000000000000100000eddeddee01121212111111212111f111f11112101000de1ded0ddedd9dd9d
-- 072:22323233333334343d434434d3323222222221221212f111f1101010100fefe018181fefeef1f1f1fe0000ee0ede000000dc02d2e000ed2f1eeeeee00f0f1feeeee12e110000e000023d123310100112000000000000010000fed9d9de0e12111f1121212111212112121120111100f1d91dededddddeed9222233333d444444444c4c4c4444d333323222222212121111f11011011f1f1efe0ef1fef1e81f1f1d0000fd00e2000000dc20ddef000dee0e2eeeee000181fefde021e10000ef0002d3233310f00e1e0000000000000000000d9d9ed0e21f12121211211121111211112111112100ed0dd8dedd9ded9ddd
-- 073:1222222223333dd4444433334c444443433332322222212221211110110ef1f181f1ff1feefe0f1fe2e0000df0ed0000004cc01dde000ed2ffdeee6ee0f0f81eeeee2e11e000ee0002342333100000110000000000000000000ddedd0fe111211121211212112121112111121f1100eed1eddd9dedded9d911121222222233333444cccc4c4c4444443d33332222222122121211010f1fef1fef1ffeeeefe0feeed0000e20e2e0f000c4cc0dde0000dde1deefeee10810efe1de12e1e0000e800d33333310f00001000000000000100000e0f0f00000111212112121111211121f112f11121100eded9deedeeedd9dde
-- 074:01101111212212222233444c4444443433433333332322221221210211111f1f1f1ffe0efe0e0efeefd1000edf0d200001cccce0ddf000eddfddd0feed0f1f81efde12e1e10002e0043434d310000010000000000000001000000000000121211121211112111211121211121111009edddddd1ded9deddd0101010110111112222334d4433332323323322222222222221212112011f1f1fef1f1feefef0f11eeed0000de0e20000ec4ccc0dde0e00ddeeddd0eee20f1ff1eede2e11e000eee04333343e0f0000000000000000000000000000000011112121121212112112121111211121000dd9d9dedeedddedded
-- 075:1000001001010101122233433332222222222222222222212121212111201f1f1f1fefeefef1f1ff1deee000ed0ed00f05ccccc50def0c0edd1ddde0eedf00f1fe1d2e21e1000fee144343c3100000000000000000000000000000000001212112121121121212121121211211100eeeddddee9ded9ddddd001000000001010011222333322221111111212121211112111f10101011ff1feff1f81fe1f18f80eedde000ed1fd1000dc4cccd0fd20d202deeddd00eed010efeee2e3e1e2000e2f3333343100000000000000000000010000000000001121212121212121121121211112112100eddde9de2dedddeddd9
-- 076:11111101000000000012222222211101011011111101201101211011f101001fe0ef1efe1f1f00f0feed2e000de02e0004ccccd5c02d00cf0d28dddd0eed0f8181e0222ee12000eee24333d310f0f0000000000000000000000000000002112112121212112121211112121111100ddd0d2ededddded9d9d21211111111111001011222222100000100100000100101010101010101011fefe0e8feef1f1f000fededdf00dd0e2000ccccddccc0de0dc01dfeddde0edd01f1f1ee2e211e1000e1243333310000000000000000000000000000000001121121211211212112112121121121200fdeed19deddd9edddddd
-- 077:212222122121111112121212110110000000001010000000010000000010001f1fef1f1feee0f0e00eedded00edfed00fc4cdccccc20d00cc0ed02dddeedd0f0f10112121e1ee00e12d3333310000000000000000000000000000000000211212121212112121212112111121100edeeededddddddddeddd222e222122222212111212222110000000000001001000001000000001000001fe0ef1eefef8002f00ededdf0fde1d0024cdccccccc0ee0cc20d1feddd1edd0180181ee2e1e131000143333d10000000000000000000000000000000001122121212121212121121211212112200eeddeddddddedd9ddddd
-- 078:221221221212122122222212121111111110010000000000000000000000000fefe0e0efee810fedf08edddd00dd0d10d4cccccccccc0e0fcc10d00eddded20010101011211e2400003d3d3d00000000000000000000000000000000001121121212121212121211121211211100eedededdddededd9dddd212212222222212212112121212121211f111111110000000000000000000001fefefefe1f10f0dede0eeedde0ddfe2044ccccccccccd0e0ccc01e00dddee2e0000101012e110440003d33400000000000000000000000000000000000211221212121212112e212211212112100ddedddddeedddddddddd
-- 079:2222222e2121221221222122121212121211111101110f100100000000000000e0e0e0e1f1f000eddee0deddd0fdd1d04c4cccccccccc1002ccd01f00dd2eee100001101e11104e4002d340010000000000000000000000000000000002121121212e212e2121212112121121100eddddededdeddddddddd2e2121222222122212212121212121211212111111f111101001011010100000fefefefe1f10ef2dddef1dedcd02dee0c44ccccccccccc000ccce18100d2e12010000010ee1001444013100d1000000000000000000000000000000001121212121212121212121212112121200eeeddeded1ddedddd9ddd
-- 080:2222222e212e222122212212121212121211120211111f1111111101000001001fe0e0e1f1f0d2fd2deeeeeddcdfdd204c4cccccccccccc00dccc0e1f0fee10201000100011102300000002ce0100000000000000000010000000000002121212121212e2121212112121212100eddd1dedddedded9ddddd2122122222222e222122212212121212112121111f1f111f11010111f11101000f1fef1f1e00ddfdddeededdedc2ddee344ccccccccccccc00cccd00e000e100200000010e1000f000000ecc2010000000000000000000000000010001212121221221212121212121211211200dedde2dedddeddddddddd
-- 081:221222212e2e222122121221221212121212112121211111f111101011011f00101fe0ef1ff0dceddddedddc22cd1dd2d4c4ccccccccccccd0cccc200f000000010010100011002222e1dcc42000000000000000000000000000000001121212212212121212121e21212112100ddeddedddeddddddddddd2222622222222e2221222e21212121212121121111f1101111011111f010010010fe0eef1100dddedddeed0e322cddde244cccccccccccccce1cccc0000000000000010010e1002ccccccc443010000000000000000000000000000002121212e221221221212121211212211081dd1ddeddddddd9dddddd
-- 082:22e22221212e222e222122122212121212121120121111111111f1010110f10f1011f1f1ff00c5ddddde12002d22dd2dedc4cccccccccccccc0ccccc0000000000000110000100eccccc4cc4d0f00000000000000000000000000000011212e22122e2212e21212121212112001d1dd1dd1dddddddddeddd2222622222221222212221221221212121121211211f1101011111110010101100fe0e0e1000dd5ddddc1e00033e2ddde244cccccccccccccccdcccc50f0000000000001000100fcc4ccc4c4300000000000000000000000000000000221221222e2212121212e212121212100edd1ddeddeddd9ddeddddd
-- 083:2122221221222e2e2221222e221212121212112111121111110101f10101f100010ef1ffef00fcddcddc2e000022eedde144ccccccccccccccccc55d52000dc1000000000100100ccccc4443400000000000000000001000000000001e212122e2221212121212121212121200dedd1ddedddddddddedddd22222222222222221222122212122121212121121f11f11f11111f01101010f11f0f1fe810000dc5dcd5d10000012e2eee2c4cccccccccccccccccc4cc100eccce0000001000000ccc4c344431000000000000000000100000000000021212e221212221212212212e21212100dd1ddedddddedddddddddd
-- 084:22222222e22e22122212212122212e21212121211211211111f10111010000010001fe01f0f00ecdcdcdde000000012e2d14cccccccccccccccc44444cc00ecccccce00000f0010dccc443c341000000000000000000000000000000121212212222121221212212122e2121002dd1dddddedddddedddddd2222212222222222122222221212221212121211211f11010111101edddddde2e2101f18e000f0dcdccdd2002e0000e2eeedc4ccccccccccccc443f0054c01ccccccccce0000000dcccc34434100000000000000000010000000000011222e222122222122121212121212110ededdddedddeddddddddddd
-- 085:222222222222221222212121222221212121212112112111111f11feddddddddde211f0ef00800eccdd2d200ec00f0012e21cccccccccccccc43000062ccc0cccccccccccce0000eccc433d3310000000000000000001000000000001212122212212122122e22212121212000ddddedddeddedddddddddd2222222222e222221222222212121221212121121111011f11f11111edededd9de200ef10000f0edddded100e5d00000edee4cccccccccccc41000ecccccc2cccccccccccccccccccccc434340000000000000000000000000000000112221212212212e21221212e22212100dededdddddedddddddddddd
-- 086:22222222222222222221221222212212212121212121121111111011dddddddddd210f1f00000f0dcd2ed000edde00000f2deccccccccc44200004ccccccccccccccccccccccccccccccc43330000000000000000000f0000000000012121222222122122212221221212e2002deddddeddddddddddddddd222222222222222222222e221222e2212121212111f11f1101111110dddddddddd1001f1000f8000cdee2000dedd000000001dcccccc3e00000eccccccccccccccccccccccccccccccccc44d200000000000000000000000000000012122212122122122e2212122e21222100dddd2dddddddddddddddddd
-- 087:22222222222222222222222222e22122122121212121211211010110eededddd9d2110ef00010000edefd000ce2dd000000200d56100000000dccccccccccccccccccccccccccccccccc433400000000000000000000000000000000e2221222122222221212221221221110fdd2dd2ddddddddddddddddd22222222222222222222222222222221221212121211f11111111101dddddddddd1010e0000000000dd0d00eddedde0000022000000000001ccccccccccccccccccccccccccc4cccccccd44300000000000000000000000000000000212e222222e2621222212221221212000eede2deddddddddddddddde
-- 088:222222222222222222222222e2212122212e212121112112011f111fedededdddd12010e000000000eefd00eddedddf00000ccddef1ee2cccccccccccccccccccccccccccccc44cccc4443410000000000000000e000000000000000222222212122222212122122122122000000000000000000000000002223222223222222222222222222222122212121121211f1121110111f1f112222220001000f00000eeee00ddddeddd00f00dccccccccccccccccccccccccccccccccccccccc434cc4d34340000000000000000fd00000000000000121212122222e2122222e22122e22e200f0e00f1f10fe0fe0e01f0e0f
-- 089:22222222222222222222222222222622121221212121112111f11111111e22222321000f000000000eefe00dddde2dde00000ccccccccccccccccccccccccccccccccccccccc4444d344d42000000000000000022001000000000001212222212212222e2622622e2221210000000000000000000000000022222222222322222222222222222222222e221212121111211101101111111222221011f008000002ee002dedddeddd00000dccccccccccccccccccccccccccccccccccccc43d4344d344000000000000000012e000000000000001221212222222e222222222e221222100dedddddededeeeedeeeeeef0
-- 090:3232322222222323222222222222222e2e22121212112121111211111333333333321110100f00000efe00dcddddeeddd0f000ccccccccccccccccccccccccccccccccccccc34444d443430000000000000000226001000000000002122222622212221212e2622212212f0eddddddededddddddddddddd022222232223222222222222222122e2222222222e2212121221e2e2e2333233232322200e00f0000020000cdcddddeddd2f000fcccccccccccccccccccccccccccccccccccc34434434440000000000000000022100100000000001221212222622212222222e2622e22200edddddeddddddddddddddddd0
-- 091:22232322222222322323222222322222222222222222e21e1110100000001000000000000f0800000e00002c5dedc2eddded000dcccccccccccccccccccccccccccccccccc44444444343000000000000000000210000000000000021222222222222122621222212221200ddded1ceddedddddddddddde0332353233333323232232332322323222221111f000000000000000000000000000000100e00f0000e000f0dcdddddf2dddee000ccccccccccccccccccccccccccccccccccc444d44d440000000000000000000f2000000000000002221262e22622222122212e22212210fddddddedddddddddddddddd10
-- 092:3232323323532d3d233222e212110000000000f0202020220222222212222222222122120e000000f0000000dccdddde2dde2f000cccccccccccccccccccccccccccccccccc4434434420f00000000000000000021000000000000121222222222122122212222221212108dededdddddddddddddddddd003d3d3d22222121000000002021222222222222223223232333333233222232222222222221f00f00f00000001ddcdddeeddd1f1000ccccccccccccccccccccccccccccccccc44443d44001000000000000000000010000000000001222e222122222222122212121222110eddeddeddddddddddddddddd00
-- 093:11000020222222222223222332233333333333333333333322223323333323332322222221f0000000000000ffdddddde2ddd00f001cccccccccccccccccccccccccccccccc344444400000000000000000000000110000000000012122222222221212222222222212200deddeddeddddddddddddddd90022222222222223233333333333433343333333333333333333343332323233222202222212f100000000000000edddddd0ed5e000002cccccccccccccccccccccccccccccc44d343420000000000000000000000001000000000001222e222222222222212122621221200ddedddddddddddddddddddde00
-- 094:2222232333333333334333333333333333333333333343333333333322222222222222f22010f00000000000010eddddde0edde00000ecccccccccccccccccccccccccccc4443444d000000000000000000000000000000000000022e2222e222122221222226222212200eddeddddddddddddddddddd8003323333323232333333332323333333333333433333333333222222222222222220202101010f000000000000000eddddd002de0010001cccccccccccccccccccccccc444c43444300000000000000000000000000000000000000222212222222222222e221221212210fd2dddddddeedddddddddddd000
-- 095:223332322333323233333433333322223323332223222222222222222222221222221212010e00000000000000000e2dd2e00ed2000000eccccccccccccccccccccc4444444444400000000000000000000000000000000000000022e222222e2222e2222122222222210fddddddddedddddddddddddd000322323233323333323332223332323222232222322223222222222022222202100000000000f0f000000000000f00feeded000edf0000002ccccccccccccccccccccc444434344000000000000000000f0000000000000000000016222e2222222222221222e21212e200edddddeeddddeddddddddddf000
-- 096:2232322222232323232223322222222322222222222222222002000020100100010000000000e0f000000000000000eeded1000ed00000000dcccccccccccccccc44443444444000000000000000006ff6532000000000000000012122222222221222222222222222200dddddeededeeddddddddddd800022222223232232232232222222222222222222202222102122f001000000000000000100000000000000000000000002e2ee0000ee000000000dcccccccccccc444444444444100000000000000006f000f6f6100111110000000122212222e222222e22212e2122e2108ddeeedddeededdddddd9dd90000
-- 097:222222221222221020222222222222f120202102201000100001000000000000000000000001ff00000000000000000fe2e2000001e00000000034cccccccc44444444444440000000000000000f0ff00600f600012111000000012222222222222222222222222122200e1eeeeeededddddde9dedde0000002100000001002002020120220010121202f21001201000001000000010000000000000000001f00000000000000000eedef000000e00000003322344cc4444444434434400000000000000000ff00ff0f6000001111110000002262222222222122221222e22222110f2eedeeeeddd9dededdedeee000f
-- 098:00000010101000012100000001010000000001000000000000000000000000100000000000008f0000000000000000000eede0000000e0000003333333333434444444444200000000000000000000000f20000000111120000002122222122222222122212221212200ee1eeedeee9ed9eeeedeedd0000e0101210021000100000010010000000000000000000000000000000000000000000000000000f00f000000000000000001ede0000000000000333333333333333333333333000000000000000000000f0020000000111111000002222122222212262222222122221200eeeeeeeeddededededed9ed0000e
-- 099:000000000000000000000000000000000000000000000000000000000000000000000000000010f8f00000f00000000000e2e00000000000024333333333333333333333331000000000000f0f0000000120000000211121000002222222222222222212622222e22200eeeeeeed9deeeeeee9eedee0000e00000000000000000000000000000000000000000000001000000000000000000000000100000010000000000000000000eee000000000000033433333333333333333334330000000000000000000000220000000121112100012e22222222222222222221212226100ee1eedeeeeeeeeeededeee800009
-- 100:00000010000000000000000000000000000000000000000000000000000000000000000000000f8f0000000000000000000ed00000000003401433433333333333333333334200000000f01211f100000220000000111f11100012222222222222221222222222e221001feeeeee1eeeeeeee9eeee0000fe00000000000000000000000000000000000000010000000000000000000000000000000000000f008000000000000000000ee00f00000034341244333333333333333433333300000000000122222222222000000011212120001e22212222222e22222e221222222f01eeefeeeffeeeeeeeeeee7e0000ee
-- 101:000000000000000000000000000000000000000000000000000000000000000000000000000001000f000000000000000000e0000000043434423343433333333333333334342000000000000212121f120000000002111212001222222222222222222222222212200ffeeefefeeeeffeeee7e7ef00007e000000000000000000000000000000000000000000000000000000001000000000000000000000800000000000000000000f000000003434344444333434333334334334333420000000000000202f20200000000002e212120022622222222e22222222e212e2222002eeefefef17fdeefefe7eef0000fe
-- 102:0000000000000000000000000000000000000000000000100000000000000000000000000000000f00000000000000000008f000000f014343443434343333333343333334200000000000000001210201000000000e21112120222222222222222212222222222e200ef1fee8feeeeefffefefee00008e70000000000000000000000000000000000001010000100000000000000000000000000101010000000000000000000000001800000000002444443443434343333333434200000000000000000001020200000000001121212202e222222222222222226212122e21081f10feeeeffff8effefeff0000fee
-- 103:00000000000000001000000000100000000000000000000000000000000000010000100000000010000000000000000000f1ff0f0f00f000024434434343433334333420000000000000000000000000012000000001212121212222222222222222222222222222100f1fefeff8feefefeffe7ef0000eff00000000000000000000001000000000010000000000000000000000000100001001000001fef1f0000000000000000000f018f81810010fee0244344343343433442000000000000000000000000000000000000000211212222e22222222222222212122126222001e81ffffeeffffeffeffff000008ef
-- 104:0000000000000000000000000000000000000100000000010100010010000010000000010e01011ff0000000000000000efe0f1f18fefeee2edee3443434343433180f10f0000f00f00000000000000000000000000062212e212222222212222122222222222262008f18feeeff1f1ffe8fff8e0000ff8f0000000000000000000100000000000000000000000101000000100000012000000201f01f1f1f1e00000000000000001f1fef1f01eeeeee2ee2eee1dddd222f0f81f08f00f0f80f000000000000000000000000000021212122262222222222222222222e22122e0010eef0f0f8fe8ff8f8fe8f00000ff8
-- 105:000000000100001001f010100000201000000000201000000001000121eeee110020ef1f1f10f10f000000000000000f0ef1f1ffe0f1eee2e2eeeee0dddd0f0ef0ef1810181801000000000000000000000000000000e2e2e226222222222222222222622212222100fef0110ef1f8ff8fef8ff00000f8ff00000100000000000010000020100000001001020000000001002120efeef1fee1010100000f001f1f0000000000000e0efeff1efefeeeeeeeeeefefdddd0e0f1f18f0f0810f10f00000000000000000000000000000126212e222222222222222e222222222122f001f1e0f80f81f8fef8ff08f0000ff8f
-- 106:0010000101000101000010220120101010000000000020100101001ef00000000fef1f0e10110801818f000000000001f1e1eef818efee2edeeeee1fddddf0f1f1f0f81818f1f0f1fff00000000000000000000000001e221222e22222222222222222222212222001f01010ef1f8fff00f80ef00008ff00000000020001000001f2f10000100200001000012201000010220e0000f000000001eeefee8f0000ef1fe000000000f1feefe1efe1e1eeeeeeeeefe0ddd2f1f81f01f1f0e0e0f1f0f18f00000000000000000000000002122122222222222212222222262222122001111f1f01f8f180ff0ef0f0000f000f
-- 107:000001010000002110100000000000010000020000000102022210101000f0000000effe0000000008001f100000000efeeeeeef1ffefeeeeeeefeefddddff81f1ff1f0e0f818f1f1fefe00000000000000000001e000e221212e222222222222222212222e222200f1f1e010ff00f8f0f00f00000008ff80101000001f2011000210001001010000000000101022222200f0080000000000000080000000000000000e00000000f1eeeeeeeeefe1eeeeeee1efedddef11f0ef1f1f0e018f1f1fef1f0000000000000000f0f80000212222222212221222222222221222212e001011f10e01ff80101ff0f00000f0000
-- 108:0000012100001020010000001000002020222010222022210100100f00f010f00000000000000000000000000000000f1feee2ddeeeefefe1f1ef1efddd2f181f1f10e81ff818fefeee0000000000000000000181f000e2e212e2222222222222212222212e22210001111118ff110101f008f00000f00f00101000001010001000020000000012222210222022221f0e0f000000000000f0000000000000000000000000000000efeeee2e5deeee1f1fefefefedddeefef1f1fef18181feeee1f000000000000000000f0f100000022212222222222222222222222222212000000000f11101f018f8f08000000f00f
-- 109:10002010100000000010001010202221201002212222feef000000000000000000000000000000000000000000000001f1eeee2edddeeeee1eefe0eedddef181f1f1f1feeeeeeeee800000000000000000000e0f0f000000222262222222222222222262621222111000000000000000f00f100000f008f00000002000001020100001022202000022222002221f1f1f10000000000000000000000000000000000000000000000feefeeeededddedeeefeefefedddef1fe81ef1eeeeeeeeef00000000000000000000000f1f00f000000112222222222222222222222221212e22e2111110000000000000000000100
-- 110:21010010010100000010122200000102222002222f1f818f8f000000000000000000000000000000000000000000000f1eeeeeeeee2ededeeeeeefeddddf1fe1eeeeeeeeeeeef000000000000000000000000f1f00f0f0100000011e222221222222e22e226222222212222212122e2111f00000000000000000000000000102f22222002222222022222221f1f0f00e00000000000000000000000000000000000000000000000eefeeeeeeeeee2e2e2eeeeefdddd1ee1feeeeeeeeeef1000000000000000000000000f1f8108100000000000000112222e2222222e1e11212122e2122122e12121212121111100000
-- 111:00001000010100222222212222020222211000000000000000000000000000000000000000000000000000000000000feeeeeeeeeeeeeeeeee2eeeeddddfefeeeef1efefef000000000000000000000000000f1ff0f0000000000000000000112222e1f81f1018f11212212e2e122121211211121112121101000011002f20222001222101101800000000000000000000000000000000000000000000000000000000000000000eeee2e2eeeeeeeeeeeeeeeeeddddeeeeeeeeef1f10000000000000000000000000000fefe0000000000000000000000000fff0e010f8f810000121212212e121212e1212112111111
-- 112:0001010022f222102222110000000000000000000000000000000000000000000000000000000000000000000000000eeeee2e2e2eeeeeeeeeeeeeedddeefeeeefefef808000000000000000000000000000f1ef0000000000000000000000001f181f1f8f100000000002e2e2121212e21211121111111102222222102022221100000000000000000000000000000000000000000000000000000000000000000000000000000eeee2ee2ee2edeeeeeeeeeeeddddfeefefeefe18f0080000080000000000000000000efe0f00000000000000000000fef1fef0f0f00000000000000121212112112112111e2121211
-- 113:00122202222221000000000000000000000000000000000000000000000000000000000000000000000000000000000eeee2e2eede2ee2eeeeeefeeddde1eeeeef1eef11e800000000000000000000000000feef0000000000000000001f1810f10810000000000000000000112121212112e2121111111122222022221000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeed2e2de2e2eeeeeeeeeeedddeeefee1eefeeef1fe808008000000000000000000f1eeef1f0f000000000000ff1fe0f1ff0000000000000000000f0111121211211111121211211
-- 114:22222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeedee2e2e2eededeeeeeeeedddeeeeeefefe1ef1eef0f00000000000000000000001f1feeeeeeeff0000000f1e01f01f0000000000000000000000100f001111212121211111111122210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eee2ed2dd2e2ee2edeeeeeeedddeeeefee1eefeeef11f80808000000000000000000feeeeeee1ff1000000fe8f1fe0e8000000000000000000000f0f000f1fee0ef11111121121111
-- 115:10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ee2e2de5de2e2e2eede2eee2dddee1eeeeeeeefefeef1f8000000000000000000000ef1eee6fe1f000000f1f1fef1ef0f0f0f0f000000000000f00000e0e0100f0f1f1111111111210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fdee2e2ddd2e2e2e2eeeeeeeedddeeeeeeeeee6eeefeef1f08080000000000000000fe1feefef1f00001f1efe0eef1f0e0ef1f1f0000000000000000f18f080f01f10f1f1011111111
-- 116:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000f2e2e2ddddedde2e2ede2eeeddddeeeeeeeeeeeef1eeeef0808008000000000000001f00f0f00000001818f1feef1f0efefeef10f00000000000000f00000000000f8000f0001121110000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000feeeddddeddededee2edee2eddddeeeeeeeeeeeeeeeeee180080808000000000000f800000000000ff1f1f1f18f1fefee1ee1ef18f00000000000000f0000000000000f00e01f00f10
-- 117:00000000000000000000000000000000000000000000000000000000000000000000000000000000000002200010202e2e2eddd5dd2deedeeedeeeddddeeeeeeeeeeeeeeefeee180000000000000000000f00000000000f180f1f1f18f81efefeef1f1f10000000000000f000000000000000000f08f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000220001202021eeeedddddd6de2e2e2eeeeeddddeee2edee2eeeeeeeeefe0808080000000000f0f00000000000f10f181f8f00f1f1feeeeeeefef8f000000000000100000000000000000001f00000
-- 118:00000000000000000000000000000000000000000000000000000000000000000000000000000000012200020010201eee2eded2ddedeee2e2edeeddddf2eeeeeeeeeeeee1eeefe00080800000000001f0000000000f1f080f08f0800010e1e1ef1fe0ef1f0000000000f0000000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000221002001212221eeededddde2dedeee2e2ededdddee2e2e2eeeeeeeeeeeeef080000000000000000000000000ef000f0100000000f0eff1fef1f1810000000000f0f0000000000000000000f8f00000
-- 119:00000000000000000000000000000000000000000000000000000000000000000000000000000222200200201022222eeeedee2d2e2ee2e2ee2eeedddde2e2eeeeeeeeeeeeeeef100808080210000000f0000000fee00f0000000000000f01f0ef1f1f1f8f0000000f0ef000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000022220001021022122221eeeee2dd2eeeeeee2e2e2eeddddeeeeeeeeeeeeeeeeeeef000080000f0000000080000001e000000000000000000000f1f18f0f8f1000000001e00f00f0000000000000000f000000
-- 120:00000000000000000000000000000000000000000000000000000000000000000000000002202210022220202202222e2eee2e2dedeeee2eedee2eddddedeeee2eeeeeeeeeefee808000000000000000f00000ef00000000000000000000000f0f018010000000001fefe01f0000000000000000f10000000000000000000000000000000000000000000000000000000000000000000000000000122022012020020222f221222eeee2e2ee2ee2e2e2e2edeeddddeede2eeeeeeeeeedeeef00800000010000220000000f0000000000000000000000000000000f000000000feef1fef0e0000000000000000f000000
-- 121:00000000000000000000000000000000000000000000000000000000000000000000022f22202022202222122222222eeeeeededeeeee2e2ee2eedddddedeeede2eeeeeeeeeee08000800000000022100000f000000000000000000000000000000000000000000eee1fefe1ff0000000000000f08000000000000000000000000000000000000000000000000000000000000000000000000023222202022100212222222222221eee2eeeeeee2eeeede2e2ddddee2e2ee2eeee2eeeeeeef0080000012010020000000000000000000000000000000000000000000000000feeffeeefe010000000000000000f00000
-- 122:000000000000000000000000000000000000000000000000000000000000000001322222220222022222022222222222eeee2e2e2eeeeeeedee2eeddde2eeeee2e2eeeeeeeeef08000000020200202000000000000000000000000000000000000000000000000feefefee1eff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000023222022202220222222222222202220ee2ee2eeee2eedee2edeeddd3deedeeee2eeeeeeeeeee00080800010201210000022200000000000000000000000000000000000000000fef1feeeeef00000000000000000000000
-- 123:0000000000000000000000000000000000000000000000000000000000000002f2222220222202212222222222222203eeeeeeeeeee2eee2eee2edddde2e2e22eeeedeeeeeee8000000002201002200000121210000000000000000000000000000000000000000180efeeee100000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222220222222012222222222023eee2ee2e2eeeee2eedeeeddddeeee2eee2e2eeee2eeef80000800200200f202001002000100000000000000000000000000000000000000f00010f1ff00000000000000000000000
-- 124:000000000000000000000000000000000000000000000000000000000000222222232222202222220222222222220322eeeeeeeeee2eeeeeeee2eddddeeeeeeeeeeeeeeeeeee008080000210210202210002221000100000000000000000000000000000000000000000f1f10000000000000000000000000000000000000000000000000000000000000000000000000000000000122222232222220222222f22222222222022221eeeeeeeeeeee2eeeedeeddddeee2eeeeeee2eeeeeff0800000001002022220001022000000000000000000000000000000000000000000000000000000000000000000000000000
-- 125:0000000000000000000000000000000000000000000000000000000002222223222222202222222022222223232222222eee2ee2eeeeeeee2eeeedddde2eee2eeeeeeeeeeee000000800002120222122020022001010000000000000000000000000000000000000000000000000000000000000000f00f00000000000000000000000000000000000000000000000000000000022222232222222022222202222222233322222221eeeeeeeeeeeeeeeee2eeddddeeeeeee2eeeeeeeef18080000001000212222f201022010000010000000000000000000000000000000000000000000000000000000000000000000
-- 126:0000000000000000000000000000000000000000000000000000000222222222222210222220212222023333202222212eeeeeeeeeeeeeeeeeeeeddddeeee2eeeeeeeeeeef80008080002001f0222022002022000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222222222022222202120222233232022222222eeeeeeeeeeeeee2ee2eeddddeeeeeeeeeeeeeeff8000000000002102012202201220201010000000000210000000000000000000000000000000000000000000000000000000000
-- 127:00000000000000000000000000000000000000000000000000000222212222222212222220200022232233222232212221eeeeeeefeee2eeeeeeedd3deeeee2eeeeeeee18000808080022000102222020000220000101000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222222022222202001122223322222222222222feeefff1ffeeeeeeeeeddddeeeeeeeeeeefef800800000000f01002022120200222012100120000001010200000000000000000000000000000000000000000000000000000000
-- 128:00000000000000000000000000000000000000000000000012222222222222222222222210010022333222232222222222fef1f18e0efeeeeeefeddddeeeeeeeeeeeff000008000000022201212220120020120000021000001000101000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001222222f232222222222222201011f1233232222222222222222f1f18f10f1eefeeefefddddff1eeeeeef000008000008000000100000010201202200010102000000001001000f000000000000000000000000000000000000000000000000000
-- 129:0000000000000000000000000000000000000000000002222222222f2222222222222121021023233222232222222222211f18108fe0fefefe081edeef1ffeeeee8000000080000000122002001020000122021000000000000100000100200100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000122222202222222222223232101210023332222222222222222222f18f8f10fe0efeff1ffeeee1801fefef00000000000000002020020000120022022000012100000000100000000000000000000000000000000000000000000000000000000000
-- 130:0000000000000000000000000000000000000000000020222f222222222223223221212101232322222222222222222222e0f810f1f0efe8e18182deef8f80efef1000000000000000220100021001000212f2010210000000010000010001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222202222223222222001f202333222223322222222222222f0e0f8f81fef1ef0f81e2eef1f1f0e0000000000000000002002121000200002022100010201000000001000000200000000000000000000000000000000000000000000000000
-- 131:0000000000000000000000000000000000000000000222f222022222023322232221201023332222222222222232222222108f1f1f0f1efeefefeeeee1f80818f8000000000000000002010202100020020202200021000000101000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000001022220222f2222202322222222202f2233222222222222222222202212f1f8f8f0e1eeeef10ef2eeef1f0f8f1000000000000000002022121200200001212000100000000000000000100000010000000000000000000000000000000000000000000000
-- 132:00000000000000000000000000000000000002222222f2222222222332323222212f12232222222222222222220202022218f1f10e0efefef1ffeeeeef810818f800000000000000002012000010021000000210000000000000012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222022202022222332323222202020232222222222222222220202202221f1f0f00ef1e1f1f0e0edee1f8f0e08000000000000000000000122001200000010000000010000000000001000010010000000000000000000000000000000000000000000000
-- 133:00000000000000000000000000000012222222220022202222222322222222212120323322222222222222201202022222108f00f1f1fef1f0e0eeeee1f180f81f00000000000000000000001000102001000000001000011210000100000001000000000000000000000000000000000000000000000000000000000000000000000000000022222222220022220222222222222222221220232322222222222221212122122222202f1f1f0efe1f1f1f1f0e2eef0f00800000000000000000000000002100200000001000000000000121010201001000001000000000000000000000000000000000000000000000
-- 134:00000000000000000000000000222322222222210202222222222221222220220223223322222222222212022f21f2220228f0f0f1fe1feff1f0eee2e1f1f010f80000000000000000000000200121000000000000020002f02000001210000101010000000000000000000000000000000000000000000000000000000000000000000022222222222222022222222222222222222f221213322322222222220202222020122220220f100f1fef1f1f1f8182ee28f000808000000000000000000000000002022001010010010000000121010100000000000000000000000000000000000000000000000000000000
-- 135:0000000000000000000000022222222222222022222222222232222222222f22333232222222222222222222022222212220f018fefe8efe0f1ffed2e08f800f00000000000000000000000101000100000000000000100010010000201000000100000000000000000000000000000000000000000000000000000000000000000002222222222222222222222222222223222221022123322322022222222212f2220222222002221f0000e0e0ff0f0f801eeee00000000000000000000000000000000002021000101000100200001210010010001000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdef0123456789abcdef
-- 002:0123456789abcdeffedcba9876543210
-- 003:000000000000ffff000000000000ffff
-- </WAVES>

-- <SFX>
-- 000:07000700171017202720273037403740475047605760577067806780779077a087a087b097c097c0a7d0b7e0b7e0c7f0d7f0d7f0e7f0f7f0f7f0f7f0590000000000
-- 001:af00bff0cf00df00ef00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00100000000000
-- 002:000010102020303030404050406050706080609060a070b070c080d080e090f090f0a0f0a0f0b0f0c0f0c0f0d0f0e0f0f0f0f0f0f0f0f0f0f0f0f000280000000000
-- 003:63b0734083d093b0a350b370c3a0d350e300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f30030b000000000
-- 004:048024e044f054d0649074809450a430b430c410c400c400c400c400d400e400e400f400f400f400f400f400f400f400f400f400f400f400f400f400200000000000
-- 016:030003000300b300c300d300039003900390b390c390d390f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300305000000000
-- 017:030003000300b300c300d300039003900390b390c390d39003e003e003e0b3e0c3e0d3e0f3e0f300f300f300f300f300f300f300f300f300f300f300482000000000
-- 018:010001100110f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100402000000000
-- 019:0200b200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200502000000000
-- 059:020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200300000000000
-- 060:0100110011002100210031003100410041005100510061006100710071008100810091009100a100a100b100b100c100c100d100d100e100e100f100302000000000
-- 061:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100302000000000
-- 062:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000302000000000
-- 063:0000100010002000200030003000400040005000500060006000700070008000800090009000a000a000b000b000c000c000d000d000e000e000f000312000000000
-- </SFX>

-- <PATTERNS>
-- 000:6008f5000000000000000000a008f5000000000000000000b008f5000000000000f008f5000000000000d008f50000006008f5000000000000000000a008f5000000000000000000b008f5000000000000f008f5000000000000d008f50000006008f5000000000000000000a008f5000000000000000000b008f5000000000000f008f5000000000000d008f50000006008f5000000000000000000a008f5000000000000000000b008f5000000000000f008f5000000000000d008f5000000
-- 001:6008f9001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b008f9a008f98008f98008f9000000000000a008f9000000000000000000000000000000000000000000000000000000b008f9a008f98008f98008f9000000000000a008f90000006008f90000008008f9d008f7000000000000000000000000000000000000000000000000
-- 002:8008f9000000a008f9b008f90000008008f90000000000005008f90000006008f98008f9000000d008f70000000000006008f9000000000000000000000000000000000000000000000000000000000000000000b008f9a008f98008f98008f9000000000000a008f9000000000000000000000000000000000000000000000000000000b008f9a008f98008f98008f9000000000000a008f90000006008f90000008008f9d008f7000000000000000000000000000000000000000000000000
-- 003:8008f9000000a008f9b008f90000008008f90000000000005008f90000006008f98008f9000000d008f7000000000000e008f70000000000006008f90000000000009008f9000000000000000000d008f9e008f9e008f9d008f99008f9000000d008f70000000000005008f90000000000008008f9000000000000b008f9d008f9d008f9b008f98008f95008f9000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:bff8f7aff8f78ff8f7810bf7010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:aff9e7aff9f7000000000000000000000000000000000000000000000000000000dff9f5bff9f7aff9f78ff9f78ff9e78ff9f7aff9e7aff9f70000006ff9e76ff9f78ff9f7dff9e5dff9e5dff9f5000000000000000000000000000000dff9f58ff9e78ff9f7aff9f7bff9e7bff9e7bff9f78ff9f75ff9e75ff9f76ff9e76ff9e76ff9f78ff9e78ff9f7dff9f5dff9e5dff9f5aff9e7aff9f7000000000000000000000000000000000000000000000000000000bff9f7aff9f78ff9f78ff9f7
-- 006:dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5
-- 007:aff9e7aff9f7000000000000000000000000000000000000000000000000000000dff9f5bff9f7aff9f78ff9f78ff9e78ff9f7000000aff9f76ff9e76ff9f70000008ff9e7dff9e5dff9e5dff9f50000000000000000000000000000000000008ff9e78ff9f7aff9f7bff9e7bff9e7bff9f78ff9f75ff9e75ff9e75ff9f76ff9f78ff9e78ff9f7dff9f56ff9f78ff9f79ff9f78ff9f76ff9f74ff9f7000000000000dff9f5eff9f5000000000000000000000000000000000000000000000000
-- 008:dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5fff8f36ff8f5aff8f56ff8f5dff8f36ff8f5aff8f56ff8f5000000000000000000030300000000000000000000000000000000000000000000000000
-- 009:4ff9e74ff9f79ff9e79ff9f78ff9f76ff9f76ff9f74ff9f76ff9f74ff9f74ff9e74ff9f74ff9e74ff9f7dff9e5eff9f54ff9e74ff9f79ff9e79ff9f7bff9f79ff9f78ff9f76ff9f76ff9f78ff9f79ff9e79ff9f79ff9e79ff9f7bff9f7dff9f7eff9f7eff9f7dff9f7bff9f7bff9e7bff9f79ff9f7bff9f7dff9f7dff9f7bff9f79ff9f79ff9e79ff9f76ff9f74ff9f76ff9f79ff9f79ff9f78ff9e78ff9f78ff9f7aff9f7aff9e7aff9e7aff9f7000000000000000000000000000000000000
-- 010:e889e34889e54889e54889f54889e54889e54889e54889f5e889e3e889e3e889e3e889f34889e54889e54889e54889f54889e54889e54889e54889f54889e54889e54889e54889f5e889e3e889e3e889e3e889f34889e54889e54889e54889f54889e54889e54889e54889f5e889e3e889e3e889e3e889f34889e54889e54889e54889f54889e54889e54889e54889f54889e54889e54889e54889f5e889e3e889e3e889e3e889f3dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56ff9f5
-- 011:9889e59889f59889e59889f58889e58889f58889e58889f54889e54889f54889e56889f59889e59889f59889e59889f59889e59889f59889e59889f58889e58889f58889e58889f54889e54889f54889f56889f59889f59889e59889f59889e58889f58889e58889f58889e54889f54889e54889e56889e59889f59889e59889f59889e59889f59889e59889f59889f58889e58889f58889e58889f54889e54889f54889f56889f5000000000000000000000000000000000000000000000000
-- 012:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff9f5bff9f7aff9f78ff9f78ff9e78ff9f7aff9e7aff9f7000000000000000000000000000000000000000000000000000000bff9f7aff9f78ff9f78ff9e78ff9e78ff9f7aff9f76ff9e76ff9f78ff9e78ff9f7dff9e5dff9e5dff9f50000000000000000000000000000000000008ff9e78ff9f7aff9f7bff9e7bff9e7bff9f78ff9e78ff9f7
-- 013:5ff9e75ff9f76ff9f78ff9e78ff9e78ff9f7dff9f5dff9e5dff9f5aff9e7aff9f7000000000000000000000000000000000000000000000000dff9f5bff9f7aff9f78ff9f78ff9f7aff9e7aff9f7000000000000000000000000000000000000000000000000000000dff9f5bff9f7aff9f78ff9f78ff9e78ff9f7000000aff9f7aff9e7aff9f70000008ff9f78aa9e78aa9e78aa9f70000000000000000000000000000000000008ff9e78ff9f7aff9f7bff9e7bff9e7bff9f78ff9e78ff9f7
-- 014:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff9f7dff9f7bff9f7bff9f7dff9e7dff9f7000000000000000000000000000000000000000000000000000000000000fff9f7dff9f7bff9f7bff9e7bff9f7000000dff9f76ff9e76ff9f7000000bff9f7dff9e5dff9e5dff9f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:5ff9e75ff9f76ff9f78ff9e78ff9e78ff9f7dff9f56ff9f78ff9f79ff9f78ff9f76ff9f74ff9f7000000dff9f5eff9f54ff9e74ff9f79ff9e79ff9f78ff9f76ff9f76ff9f74ff9f76ff9f74ff9f74ff9e74ff9f74ff9e74ff9f7dff9f5eff9f54ff9e74ff9f79ff9e79ff9f7bff9f79ff9f78ff9f76ff9f76ff9f78ff9f79ff9e79ff9f79ff9e79ff9f7bff9f7dff9f7eff9f7eff9f7dff9e7dff9f7bff9e7bff9f79ff9f7bff9f7dff9f7dff9f7bff9f79ff9f79ff9e79ff9f76ff9f74ff9f7
-- 016:dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56aa9f5daa9f36aa9f5aaa9f56aa9f5faa9f30000004ff9f54ff9f50000000000004ff9f54ff9f5000000eff9f3eff9f3000000dff9f3dff9f30000000000004ff9f54ff9f50000000000004ff9f54ff9f5000000eff9f3eff9f3000000dff9f3dff9f30000000000004ff9f54ff9f50000000000004ff9f54ff9f5000000eff9f3eff9f3000000dff9f3dff9f30000000000004ff9f54ff9f50000000000004ff9f54ff9f5000000eff9f3
-- 017:6ff9f79ff9f79ff9f78ff9e78ff9f78ff9f7aff9f7aff9e7aff9e7aff9f76ff9f7fff9e5fff9e5fff9f5fff9f56ff9e76ff9e76ff9f76ff9f7bff9e7bff9f7aff9e7aff9f78ff9f7aff9e7aff9e7aff9e7aff9f7fff9e5fff9e5fff9f5fff9f56ff9e76ff9e76ff9f76ff9f7bff9e7bff9f7aff9e7aff9f78ff9f7aff9e7aff9e7aff9e7aff9f7fff9e5fff9e5fff9f5fff9f56ff9e76ff9e76ff9f76ff9f7bff9e7bff9f7aff9e7aff9f78ff9f7aff9e7aff9e7aff9e7aff9f7fff9e5fff9e5
-- 018:eff9f3000000dff9f3dff9f30000000000004ff9f54ff9f5000000000000000000dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56ff9f5dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56ff9f5dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56ff9f5dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56ff9f5dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56ff9f5dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56ff9f5dff9f36ff9f5aff9f56ff9f5fff9f3
-- 019:fff9e5fff9f56ff9e76ff9e76ff9f76ff9f7bff9e7bff9f7aff9e7aff9f78ff9f7aff9e7aff9e7aff9e7aff9e7aff9e7aff9e7aff9f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:6ff9f5aff9f56ff9f5dff9f36ff9f5aff9f56ff9f5fff9f3dff9f36ff9f5aff9f56ff9f5fff9f36ff9f5aff9f56ff9f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:9008e79008e79008f79008e79008e79008f74008e94008f94008e94008f9b008e7b008f7c008e7c008e7c008e7c008f79008e79008e79008f79008e79008e79008f75008e95008f95008e95008f9b008e7b008f7c008e7c008e7c008e7c008f77008e77008e77008f77008e77008e77008f74008e94008f94008e94008f9b008e7b008f7c008e7c008e7c008e7c008f7e008e7e008e7e008f7e008e7e008e7e008f7c008e7c008f7c008e7c008f7b008e7b008f7e008e7e008e7e008e7e008f7
-- 022:0000000000000000000000000000000000000000000000000000000000000000000000009008e79008e79008e79008f70000000000000000000000000000000000000000000000000000000000000000000000009008e79008e79008e79008f70000000000000000000000000000000000000000000000000000000000000000000000007008e77008e77008e77008f7000000000000000000000000000000000000000000000000000000000000000000000000b008e7b008e7b008e7b008f7
-- 023:4999d74998d74a88d74998d748a8d74998d74a88d74998d748a8d74998d74a88d74998d748a8d74998d74a88d74998d7c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5e008d5
-- 024:c999d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d5c008d59008d59008d59008d59008d59008d59008d59008d59008d59008d59008d59008d59008d59008d59008d59008d59008d57008d57008d57008d57008d57008d57008d57008d57008d57008d57008d57008d57008d57008d57008d57008d57008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5b008d5
-- 025:9008e79008f79008e79008f79008e79008f74008e94008f94008e94008f9b008e7b008f7c008e7c008e7c008e7c008f79008e79008f79008e79008f79008e79008f75008e95008f95008e95008f9b008e7b008f7c008e7c008e7c008e7c008f77008e77008f77008e77008f77008e77008f74008e94008f94008e94008f9b008e7b008f7c008e7c008e7c008e7c008f7e008e7e008f7e008e7e008f7e008e7e008f7c008e7c008f7c008e7c008f7b008e7b008f7e008e7e008e7e008e7eff9f7
-- 026:9ff9e94999ebbaa9e9cbb9e99ff9e94999ebbaa9e9cbb9e99ff9e94999ebbaa9e9cff9e9e999e9caa9e9bbb9e9cff9e99999e94aa9ebbbb9e9cff9e99999e94aa9ebbbb9e9cff9e99999e94aa9ebbbb9e9cff9e9e999e9caa9e9bbb9e9cff9e99ff9e94999ebbaa9e9cbb9e99ff9e94999ebbaa9e9cbb9e99ff9e94999ebbaa9e9cff9e9e999e9caa9e9bbb9e9cff9e99999e94aa9ebbbb9e9cff9e99999e94aa9ebbbb9e9cff9e99999e94aa9ebbbb9e9cff9e9e999e9caa9e9bbf9e9cff9e9
-- 027:9008c59008c59008c59008c59008c59008c59008c59008c54008c74008c74008c74008c7b008c5b008c5c008c5c008c55008c55008c55008c55008c55008c55008c55008c55008c57008c57008c57008c57008c58008c58008c58008c58008c59008c59008c59008c59008c59008c59008c59008c59008c54008c74008c74008c74008c7b008c5b008c5c008c5c008c55008c55008c55008c55008c55008c55008c55008c55008c57008c57008c57008c57008c58008c58008c58008c58008c5
-- 028:9008c79008c79008c79008c79008c79008c79008c79008c74008c94008c94008c94008c9b008c7b008c7c008c7c008c75008c75008c75008c75008c75008c75008c75008c75008c77008c77008c77008c77008c78008c78008c78008c78008c79008c79008c79008c79008c79008c79008c79008c79008c74008c94008c94008c94008c9b008c7b008c7c008c7c008c75008c75008c75008c75008c75008c75008c75008c75008c77008c77008c77008c77008c78008c78008c78008c78008c7
-- 029:9008e74008e9b008e7c008e79008e74008e9b008e7c008e79008e74008e9b008e7c008e7e008e7c008e7b008e7c008e79008e74008e9b008e7c008e79008e74008e9b008e7c008e79008e74008e9b008e7c008e7e008e7c008e7b008e7c008e79008e74008e9b008e7c008e79008e74008e9b008e7c008e79008e74008e9b008e7c008e7e008e7c008e7b008e7c008e79008e74008e9b008e7c008e79008e74008e9b008e7c008e79008e74008e9b008e7c008e7e008e7c008e7b008e7c008e7
-- 030:9008e99008f9000000000000000000000000000000000000040300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 031:9008e79008f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:9008e90000004008eb000000c008e9000000e008e9000000b008e9000000c008e90000009008e90000008008e90000009008e90000004008eb000000c008e9000000e008e90000005008eb000000b008e9000000e008e90000008008e90000009008e90000004008eb000000c008e9000000e008e9000000b008e9000000c008e90000009008e90000008008e90000009008e90000004008eb000000c008e9000000e008e90000005008eb000000b008e9000000e008e90000008008e9000000
-- 033:9008e70000004008e9000000c008e7000000e008e7000000b008e7000000c008e70000009008e70000008008e70000009008e70000004008e9000000c008e7000000e008e70000005008e9000000b008e7000000e008e70000008008e70000009008e70000004008e9000000c008e7000000e008e7000000b008e7000000c008e70000009008e70000008008e70000009008e70000004008e9000000c008e7000000e008e70000005008e9000000b008e7000000e008e70000008008e7000000
-- 034:9008d94008dbc008d9e008d9b008d9c008d99008d98008d99008d94008dbc008d9e008d95008dbb008d9e008d98008d99008d94008dbc008d9e008d9b008d9c008d99008d98008d99008d94008dbc008d9e008d95008dbb008d9e008d98008d99008d94008dbc008d9e008d9b008d9c008d99008d98008d99008d94008dbc008d9e008d95008dbb008d9e008d98008d99008d94008dbc008d9e008d9b008d9c008d99008d98008d99008d94008dbc008d9e008d95008dbb008d9e008d98008d9
-- 035:9008d54008d7c008d5e008d5b008d5c008d59008d58008d59008d54008d7c008d5e008d55008d7b008d5e008d58008d59008d54008d7c008d5e008d5b008d5c008d59008d58008d59008d54008d7c008d5e008d55008d7b008d5e008d58008d59008d54008d7c008d5e008d5b008d5c008d59008d58008d59008d54008d7c008d5e008d55008d7b008d5e008d58008d59008d54008d7c008d5e008d5b008d5c008d59008d58008d59008d54008d7c008d5e008d55008d7b008d5e008d58008d5
-- 036:9008d94008dbb008d9c008d99008d94008dbb008d9c008d99008d94008dbb008d9c008d9e008d9c008d9b008d9c008d99008d94008dbb008d9c008d99008d94008dbb008d9c008d99008d94008dbb008d9c008d9e008d9c008d9b008d9c008d99008d94008dbb008d9c008d99008d94008dbb008d9c008d99008d94008dbb008d9c008d9e008d9c008d9b008d9c008d99008d94008dbb008d9c008d99008d94008dbb008d9c008d99008d94008dbb008d9c008d9e008d9c008d9b008d9c008d9
-- 037:9008d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:9008d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 039:9008e99008e99008f90000009008e99008e99008f9000000c008e9c008e9c008e9c008e9c008f9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:9008e79008e79008f70000009008e79008e79008f70000009008e79008e79008e79008e79008f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 041:9008d79008d79008c70000009008d79008d79008c7000000c008d7c008d7c008d7c008d7c008c7000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:9008d59008d59008c50000009008d59008d59008c5000000c008d5c008d5c008d5c008d5c008c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 043:9008c5902cc59008c59008c59008c59008c59008c59008c54008c74008c74008c74008c7b008c5b008c5c008c5c008c55008c55008c55008c55008c55008c55008c55008c55008c57008c57008c57008c57008c58008c58008c58008c58008c59008c59028c59008c59008c59008c59008c59008c59008c54008c74008c74008c74008c7b008c5b008c5c008c5c008c55008c55008c55008c55008c55008c55008c55008c55008c57008c57008c57008c57008c58008c58008c58008c58008c5
-- 044:9428d79428c74008d94008c9c008d7c008c7e008d7e008c7b008d7b008c7c008d7c008c79008d79008c78008d78008c79008d79008c74008d94008c9c008d7c008c7e008d7e008c75008d95008c9b008d7b008c7e008d7e008c78008d78008c79008d79008c74008d94008c9c008d7c008c7e008d7e008c7b008d7b008c7c008d7c008c79008d79008c78008d78008c79008d79008c74008d94008c9c008d7c008c7e008d7e008c75008d95008c9b008d7b008c7e008d7e008c78008d78008c7
-- 045:9028c3902cc39008c39008c39008c39008c39008c39008c34008c54008c54008c54008c5b008c3b008c3c008c3c008c35008c35008c35008c35008c35008c35008c35008c35008c37008c37008c37008c37008c38008c38008c38008c38008c39008c39028c39008c39008c39008c39008c39008c39008c34008c54008c54008c54008c5b008c3b008c3c008c3c008c35008c35008c35008c35008c35008c35008c35008c35008c37008c37008c37008c37008c38008c38008c38008c38008c3
-- 046:9428d59008c54008d74008c7c008d5c008c5e008d5e008c5b008d5b008c5c008d5c008c59008d59008c58008d58008c59008d59008c54008d74008c7c008d5c008c5e008d5e008c55008d75008c7b008d5b008c5e008d5e008c58008d58008c59008d59008c54008d74008c7c008d5c008c5e008d5e008c5b008d5b008c5c008d5c008c59008d59008c58008d58008c59008d59008c54008d74008c7c008d5c008c5e008d5e008c55008d75008c7b008d5b008c5e008d5e008c58008d58008c5
-- 047:9428e79428f74008e94008f9c008e7c008f7e008e7e008f7b008e7b008f7c008e7c008f79008e79008f78008e78008f79008e79008f74008e94008f9c008e7c008f7e008e7e008f75008e95008f9b008e7b008f7e008e7e008f78008e78008f79008e79008f74008e94008f9c008e7c008f7e008e7e008f7b008e7b008f7c008e7c008f79008e79008f78008e78008f79008e79008f74008e94008f9c008e7c008f7e008e7e008f75008e95008f9b008e7b008f7e008e7e008f78008e78008f7
-- 048:9428e59428f54008e74008f7c008e5c008f5e008e5e008f5b008e5b008f5c008e5c008f59008e59008f58008e58008f59008e59008f54008e74008f7c008e5c008f5e008e5e008f55008e75008f7b008e5b008f5e008e5e008f58008e58008f59008e59008f54008e74008f7c008e5c008f5e008e5e008f5b008e5b008f5c008e5c008f59008e59008f58008e58008f59008e59008f54008e74008f7c008e5c008f5e008e5e008f55008e75008f7b008e5b008f5e008e5e008f58008e58008f5
-- 049:9028b59028b59008b59008b59008b59008b59008b59008b54008b74008b74008b74008b7b008b5b008b5c008b5c008b55008b55008b55008b55008b55008b55008b55008b55008b57008b57008b57008b57008b58008b58008b58008b58008b59008b59028b59008b59008b59008b59008b59008b59008b54008b74008b74008b74008b7b008b5b008b5c008b5c008b55008b55008b55008b55008b55008b55008b55008b55008b57008b57008b57008b57008b58008b58008b58008b5870bb5
-- 050:9428b99428b94008bb4008bbc008b9c008b9e008b9e008b9b008b9b008b9c008b9c008b99008b99008b98008b98008b99008b99008b94008bb4008bbc008b9c008b9e008b9e008b95008bb5008bbb008b9b008b9e008b9e008b98008b98008b99008b99008b94008bb4008bbc008b9c008b9e008b9e008b9b008b9b008b9c008b9c008b99008b99008b98008b98008b99008b99008b94008bb4008bbc008b9c008b9e008b9e008b95008bb5008bbb008b9b008b9e008b9e008b98008b98008b9
-- </PATTERNS>

-- <TRACKS>
-- 000:0001800001c00001010000000000000000000000000000000000000000000000000000000000000000000000000000002e0000
-- 001:795856795856796856796856000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:0c6c57b97c57b97c570c7020048c571a8c570c8c57329c57b596e986aaea000000000000000000000000000000000000000060
-- 003:00000b000d2b000e2b0cbd2b00003b04c03b0000000002fc000000000000000000000000000000000000000000000000e10021
-- 007:5000006c1000842000ac2c00dc1000ec1f000540002d4000455000000000000000000000000000000000000000000000ae0060
-- </TRACKS>

-- <SCREEN>
-- 000:666666666666667777777775555555556666777777777555555556666666655555556666666666666666677777777556666666676667755555555566666666555555566666666666666677777775555555566666666777777775555555556666666666666666666677777775555555566666666666666666
-- 001:566666666666666666677777777555555555777777775555555566666666665555556666666677766666666777777777556666666775555555556666666666555555566666666666666667777777555555566667777777775555555556666666666666666666666777777775555555666666666666666777
-- 002:555566666666776666666667777777755555666677775555555566666666666665566666666777777766666666777777776566677555555555666666666666665556666666677766666667777777755555557777777775555555566666666655566666666666666777777755555556666666666677777777
-- 003:666566666666777777766666666777777777666666655555555666666666666666666666666667777666666666666777777776655555555566666666666666666666666677777776666666777777755556667777755555555566666666555555566666666666666777777755555556666667777777775555
-- 004:666666666666666777776666666666677777777766655555556666666666666666666666666666666666666666666677777777655555556666666666666666666666666667777766666666677777776666666755555555666666666666555566666666766666667777777555555566677777777555555556
-- 005:666655666666666666666666666666666667777777665555555566666666666655566666666666666666666666666777777766666555555566666666666556666666666666666666666666667777777666655555555666666666666666566666667777766666667777777555556777777755555555666666
-- 006:666655555566666666666666666666666667777777666666555555556666666555555566666667666666666666677777775556666675555555666666655555566666666666666666666666667777777755555556666666666666666666666666777777666666667777775666666775555555566666666655
-- 007:555666666555666666667666666666666667777777556666677755555556666666655666666677777766666667777777555555567777755555556666665555666666667666666666666667777777666655555556666666666665666666666666776666666666677777776666555555556666666666666556
-- 008:777555556666666666667777776666666677777775555555677777775555555666666666666666777666666677777755555555666777777555555666666666666667777766666666667777777556666675555556666666655555666666666666666666666666777777765555555666666666666666666666
-- 009:667777755555566666666666777666666677777775555556666667777777555555566666666666666666667777775555555566666667777775555556666666666667777666666677777777555555677777555555666666555566666667666666666666667777777666655555566666666666566666666666
-- 010:666666677777555556666666666666666677777755555556666666666777777755555556666666666666677777755555556666666666677777755555566666666666666666677777775555555666677777755555566666666666677777666666666777777755666667555555666666655555666666666666
-- 011:556666666666777775555566666666666777777755555566666666666666667777775555555666666667777775555555666666666666666777777555555666666666666677777775555555666666667777755555566666666666677766666677777775555555777775555556666665556666666776666666
-- 012:666566666667666667777755555666666777777555555666666556666666666666777777555555566777777555555566666655666666666666777775555556666666677777775555556666666666667777775555556666666666666666777777555555566667777775555556666666666677777666666677
-- 013:666666666666677776666677777555566777777555555666666555556666667766666677777755556667755555556666666555556666666666667777755555566677777755555556666666666666666777777555556666666666677777775555556666666667777755555566666666666766666677777775
-- 014:566665555666666666666666666777756666675555556666666666666666667777766666667777777665555555666666666666666666777776666677777555566777755555566666655555666666666677777755555666666777777555555666666666666667777755555666666666666677777755555556
-- 015:775555666666666667766666666666677777665555566666666666666666666666666666666677777766555556666666666666666666667766666666777776666655555566666666665566666677666667777755555677777755555566666655666666666677777555556666666677777755555566666666
-- 016:666777775555666666667776666666777777766666555555666666555556666677666666666777775556667755556666655555666666666666666666677777655555666666666666666666667777666666777776666675555556666666655556666676666677777555556677777755555566666566666666
-- 017:666666666777775555666666666667777777555555777775555556666666666667776666677777555555667777755555666656666677776666666677777566666555556666665555666666666666666666677777555555666666666666666666777776666777775566677555555666666655556666666666
-- 018:655556666666666777775556666677777755555556666666777775555556666666666667777755555566666667777755555666666666766666777777555556677775555566666566666777666666667777776666655556666666555666666666666666666777776555555666666666666666677777666677
-- 019:666666666666777766666777755667777555555666666666666666777775555566666677775555556666666666666777755555666666666777777555556666666777755555666666666766666777777555556777755555666655666667766666666677777666655555666666655666666666666666666777
-- 020:566666555566666666666666666777765555556666666655566666666666777775556677755555666665555566666666777775555666777775555566666666666667777555556666666667777755555666666677775555666666666766666677777555557777755556666556666677666666667777766666
-- 021:777755556666666667776666666777775666755556666666666666677766666666777775555566666666666666677776666677775666775555566666655556666666677775555566777775555566666666666667777555566666666777775555566666667777555566666666676666677775555567777766
-- 022:666666677775555666666666666777755555666777755566665666667666666667777556667555566665555666666666666666777775555666666666666666677766666777756667555556666665556666666666777755556777775555566665666666667777555566666667777755556666666677776666
-- 023:666655666666667777555566667777755556666666666777755566666666666777755555666677775555666666677766666777755556777555666655566666666666666777776555566666666666666667666666777766665555666666665666667666677775555777775555666665666666667777666665
-- 024:666666666666667777666777756667755556666655556666666777755566677775555566666666666777555566666666777755556666667777555566666667666677777555567775555666656666776666666777766665555666665566666666666666677776555566666666666667777666777766666555
-- 025:677755566665556666666666667777665555666666666666667666666777766555556666666566667766677775556777755556666556666666777555566666777755556666666677755556666666666777755556667777555666666677776666777755567755556665555666666666666777776666655555
-- 026:556666666777555566666666667777555566777555566666667776666677775666555566665556666666666667777555566666666666667776666777566675555666665556666666777555566777755556666666666777755566666667777555566666777755566666666666777755556777766665555555
-- 027:555666665556666667777555667777555666666666677755556666667777555566666777555666666676667777555567775556665666677666666777566655566666566666666666667776655566666666666677766677755677755556665556666666777555666777755556666666667776666555555565
-- 028:756675556665556666666666667775555666666666667776666777666755556666555666666777555667777555666666666777755566666677755556666677755566666676666777555577775556665666776666677776665556666656666666666667776655566666666666777666777666655555555565
-- 029:775556666667775556666666667775556667755566666677766667775566755566555666666666667776555666666666667766667776667555666665566676677755566777555666666666677755666666777555566666777555666667666777555567775556666667776666777766656665555556555665
-- 030:776555666666666677666777566775556665556666677755566777555566666667775556666667775556666777556666667666677755577755666556667666667777665566666566666766666777655556666666667766677555777555666656666667755566667775556666666776666555555556555655
-- 031:677755566677755666666766677755577755666566676666667776555666666666676666777665556666656667666777557775556665666666775556667775556666667775566666666777555667775566666777666777556755566555666666666777655666666666667666677766665555565565555555
-- 032:667765556666666667766777567755566655666667755566777555666666777556666667775566667755666667766777555775556655666666667776655666666666666666776655566666666776677755777556665566666775566677755566666677555666666777555667776665455555655555555555
-- 033:566677555666667775566666677755666775566666776677755675566555666666667765566666666677666776655566665666766775557775566656666775556667775556666775556666666775556777556666677666777667556655566666666777556666666667766677666555455555655555555555
-- 034:677667775577556655666666677665566666666766667765556666566766777567755666566667755566777556666677556666667755555555566667766677556755665566666666776556666666676666776655666656666677555777556656666775566667755566667766655555655555555555565555
-- 035:666666677655666666666666776556666566766775577555665666677556677755666677556666667755667755666677667755555555555555555555566666666766677675566655666677556775566666667755666775556667755666666777556775566667766777665665555554665555555555655556
-- 036:566666667755666666676667767556665666677557775566666775566677556666775666666775567755666676667755555555556666655556655555555556655566556667755677556666667556666775566677566667667755775566667666777655666566666667766555555554555555655555655556
-- 037:666666666666655665666666675566666667667567556656666755677556666675566677556667756667667755555555576667766566655666667755665555555556755665566677566775566667756666775566775666666775577566566666677656665666666776655565565556555555655555655555
-- 038:555555556666666666666666666666656667667756556556666677556666666677655666567677567555555555566775566675566667755775666776677675665555555555666666766766556656667756775566667756667756667556666677567556667666766665556565555556556556555555555555
-- 039:555555555555555555555555555666666666665666666666575565566755677566667566677655555557667555566666667755666666645656666676755755656665566555555555666775677566676775655656666676566666766766566566677577566666766555545555556445556555555555555555
-- 040:655555555555665555556655555555555555554665555556666666666666666665677666666546566666666665666565676676566566645656666767767565666755755555555555556756666675756666666765666676676566567675755656675667666655654556565555655545555555555555555555
-- 041:5555555555555555555566555556655555222222222225555555555555555555555555555555465555555555545555666666666aaa56745667566755555555555555676676565665675666676765565667567566675667666666666666666666666655555546555555556555555565555555555555555555
-- 042:555555665555555555555555555555522222222222222555555655566555655565545555555646565555565564555555545555aaaaaa545555566666566665666665765666675755667667666666656666666666555555554655555555555555556555665546555555555655555465555555555555555555
-- 043:555555566555555665555555556622222277777677722222555555555555555555546555555546555555555554555555545655aa000aa45455555555554555dd6655666666665544555555555555545555555556556555554656555556555555555555555545545565455555555455565555555555555555
-- 044:5555555555555555555555555522222777777776777777222225655555565556545465565655565555655565545655655455aa000000a4545555555555665500d645556565656544555655555555545555555555555555554655556555655555655556545445545555655555555655565555555555555555
-- 045:5665555556665555555555555222777777777776677777777222555555555555555545555555555555555555545555555455a00000000455556565555465d5000545555555555544565555565564545556556555555555554655555555555555555555555465555555555555555655555555555555555555
-- 046:5555555555555555555555555222777777777776677777777772225555555555555546555555555655565555545555b5546aa0000000045556555b55556505000d65555555555564555555555555565655555555555555554665556555555555555555555465565554555555554555555555555555555555
-- 047:55555555555555555555555522277777777777776777777777777225555555555555455555555555b5555555545555b5546aa00000000455555b5b55556d05000b65555555555564555555555555565555555555555555556555555555555555555555555455555556555555556555555555555555555555
-- 048:55555555555555556655552222777777777777776777777777777722256555554545455556554465c5555565545555c5446aa0000000045a55b5bc55556d05000c6555b555555565555555555555465555555555555555546555555556555655555545455455455545555655556555556555655555545544
-- 049:5555555555555555555552227777777777777777677777777777777722555555555545555555546b5555555555555b55546a00000000045556cbc55bc56d0b00cd6555c5b55b5566555555555555466555555555555555546565555555555555555555554455555555555554445555556555655555545545
-- 050:556665555555555555522222777777777777777766aaaaaaaaaaaaaaa225555555554655555554656555bc5555555c55546a000000000455555bc65c55d0bc00006555bc554c5545555555554555465555555555555555546555555555555555555555554555655545555555545555555556555555445445
-- 051:655665555555555555522227777777777777777776aaaaabbbbaaaaaaa22555455554655555555655555b55565555c5554aa0bc000000455555c555555d0bc00004556c555b55546565555555545465555555555555555546555555555655555545555554555555565555555565555555555555555555545
-- 052:655555555555555555552277777777777777777776aaaabbbbbbbaaaaa22255555455455555455655555c5555555555455aabc000000045556555b5555dbc50000455b6555c45445555555555555456556555555555555546655555555555555555545554554555555555555466555555555555555555555
-- 053:655555555555555555222277777777777777777776aaabbbbbbbbbaaaaaa22555555546555555555555b65555545555555aacc000000045555556c5555dc05000045bc555b555445555554555455455555565555555555565555555555555555555555544555555555555555455555555555555555555555
-- 054:6655555555555555552222777777777777777777766aabbbbbbbbbaaaaaa22555555545555555555655c55555545555555aac000000004555555555555d005000d45c5555c555445556555555555455555555545555555465555555565555555555555545555555455555555655555555555555555555554
-- 055:6655555555555665522277777777777777777777776aaabbbbbbbaaaaaaa22555455545555554555555555565545555555aa000000000445555555455b6005000d45555555555445555554555555655555555555555555465655555555554555555555545555554655555555655555555555555555555554
-- 056:6655566555555555522227777777777777777777776bbaabbbbbaaaaaaaa22555555545555455546555c55555545555555ba000000000445555555555c6005000d45555555555445655455555555655555555545555555465555556555555555555555545545555555555554555555555555555555555554
-- 057:6665555555555555522227777777777777777777766bbbaaabbaaaaaaaaa22255555546555555546565555655545555555caa0000000004555655555556d05000545555554545445555555555554655655555555555555465555555555555555555555445555555665555554555555555555555555555544
-- 058:56655555555555555522277777777777777777766766bbbbaaaaaaaaaaaaaa224555456555555546555555555545555555caa00000000045555c55555c6d0500d445555555555445555555455554655555555555555555455555555555555554555545455556554555555456555555555555555555555544
-- 059:56655555555555555522227777777777777777667766bbbbbaaaaaaaaaaaaa2255555545555545565555555555455555554aa0000000004555555555b566d50d5b4555555b454445555545555554655555555555554555655555555545555555555555455555556555555546555555655555555555555446
-- 060:54665555555555555522227777777777777777667776bbbbbbbaaaaaaaaaaa22555555455555555655555555455555555545a0000000004555555555c56555d44c444444bc555445555555455554655554554554555554655555555555555555555555455455555555555545555555655555555555555446
-- 061:55665566655555555222777777777777777777767776bbbbbbbbaaaaaaaaaa22555555455555555555b65555555555545545a00000000a4555555555555445233343423bc3344544455555555554555555555555555554655555555555555555545554455555555565555566555555555555455555555446
-- 062:556665555555555552222777777777777777777766766bbaaabbbbbbaaaaaa22555555455555555555c555555555455555465aa000000a45555554442233352333432233334b4233423444444554555555555545545454655555545554554555555554555555565555555566555555555555455555554466
-- 063:554665555555555552222777777777777777777777666baaaaabbbbbaaaaaaa225555546555555555555555b55555555554656a00000a5455555523334234533234342b233334323333342333442444444555555555554656555555555555555555554555555555555545455565555555554455555554466
-- 064:555665555555555555222777777777777777777777776bbbaaaaaaaaaaaaaaa22555545655555554655555bb555455545446555aaaaa444533444444444245b3334423c343432323342423334233423423334444444554555555555555554554555554554554555555545455565555555555555555554665
-- 065:545666555555665555222277777777777777777777776bbbbbaaaaaaaaaaaa2255455554555555546555555c55545555b5465544423343453232333444444bc55243233424233442334233423334242334334323233343444444555555555555554544555555455555555655555555555555555455544665
-- 066:455466555555555555222277777777777777777777776aabbbbbaaaaaaaaaa2255555554555545546555555555545555c4454233b3424245333442b333334b444445444233334434423342333423423343432333333432333434244444444555555545555555655555554555555555555555554455544665
-- 067:5555665555555555555222777777777777777777777766aabbbaaaaaaaaaaa225544444344555555655555555554444423333424b3234345323233c343233c434444444444444433342333423342333342423233334323233334323333342444444445555555555555554555555555555555554555546655
-- 068:5555666555555555555222277777777777777777777776abbbaaaaaaaaaaa224423333434434455565555554444453422334233bc423424543342bc3233334223343434244444434234233334233442334233334244233433432332333343233334345545555555555556555556555555555554555446655
-- 069:5555566555555555555222277777777777777777777776bbbaaaaaaaaaa23343342323233333444555444423233453442342333c4233444534233c34424223343343323333444422333343424223233422342333442334423342334344242323433444554544555455556655555555555555555555446655
-- 070:5555566555555555555522277777777777777777777776bbaaaaa23342333422333422342333434454552333334453333433432c3323344544233334223342233453333544442333334432232333334223333434432232233422442333342333422344565556555555545555555555555555555554466555
-- 071:555554665555555555555522277777777777777777777662333334344342332333423422333342333444544233335422423334334432334533334323333343423453355442234223334423334223442334334234232333344323323333343233333334455555555555565555555555555555555554466555
-- 072:555455665555665555555522227777777777777772334344234233343344332332333334223333343443444444335234422333442333424534233343442442323455544223333333442233333434234233233442334223334223334223442333434424455555555555565555655555555555555554465555
-- 073:555555665555555555555522227777777733233323434224423333342233422333422333342234223344334444445333334422333334334542333233342344234454423334423334233333422442333433343323323333344223333343443423322334455545555555455555555545555555555544665566
-- 074:555455466555555555555544222222333334224423333333443223333333344223333343442422332333422344445554423334422334234543342242232333444452333333333432233333434224223323344233442333342233344223442333433422445565555555455555555455555545555544665566
-- 075:554554566555555444444432233333433423422322334423344233334423333422334423334334224223233333444445553333344322334534344244223444444233442333342233334223342233343342342332333334432333333433433223323333445455555555655555555555555545555546655666
-- 076:555555566544444422333442233442333434422442333343334432233233333343223333343342342233233344233444455544233334424534223334344444223233333344323333334334432233333434424422332333422334423333422333344223445565555555655555555555555445555446655665
-- 077:555555545522332333333442233333343344342233233334223442333334423333422333422333434422342232333334444444423333334522333335544423422322333442334423333342233334223344223334344224423323333344322333333333444655555454555555555555555555555446655565
-- 078:655555542232333342233442233334223333442233422333443344234233233333344323333333433443223332333344234444444434424534425554442333334422344223334333443422322333333442233333343344332233323333422344233333344555555456555555555555555555555466555555
-- 079:655555422344233334333443322332333333344223333334434423422332233344234422333334422333442233344233333344444444324543555444233323333334432233333343344244223323334422344223333344233334422334422333433442244555555556565555555555555555554466555555
-- 080:456554422333333443442342233223334422344223333344223333442233442333343344224423323343334433233323333333433444444555544224422332333342233442233334422333344422344223334433442342233233333344322333333333344455555545565555555555555555554465555555
-- 081:565554223333344223333442233442233334334422422332334333444322333333333344322333323343342244223323333442233444444544422333334422334223333433344234223223333334442233333334333443223333233334422442233233344455555545555555545555555555544665555555
-- 082:445544224423323343333443223332333333344322333323343344234422332333344233344223333342233333442233442233334334444542233233333334432233333334333433223333233434422442223333334422333442233334422333334422334455455565555545545555555555544665555555
-- 083:555542233333334433442442233223333442234442233333442233334442233442233334334422342233233433334433233333333333344322333323343344224422332333344223344422333344223333344222334223333443344223422322333333344345545455555545555555555555546655555555
-- 084:556442233333344223333442233344223333433442224422333334333444332233233333333443223333333443344234223332233334223344222333334422333334422333442233334334422442233233333334433223332333333334432233332334334445555455555545555545555555446655555555
-- 085:554422334422333344333442342233223333333444223333333343334433422333223333442234422233333344223333442223334422333333344223442233333433344433223332333333334432233333334433442342223322333344223344222333334445555655555555555545555555446655555555
-- 086:554532233333333333334432233333333433442244222332333334422334442233333442233333444223334422333343334422342233223333333443222333333334333443322333323343344223442233323333442233344222333344223333334442233444555655555555555545555555466555555555
-- 087:554222333233333442234442233333334422333344422333344223333433442223442233333433334423322333233333333344222333333344333443342233322333344422344422333333442223333444223334422333333334422244223323334333344334554555555555555555555554466555555555
-- 088:544223333334422333334442233344223333343334422344223323333333344332233333333333334433223333333343344422442223323333344223334422233333442233333344422334442233334433444223422332233333333443223333333334333444556555555555555555554554465566555555
-- 089:542223444223333444334442342223322333333334442233333333344333443322233332333334442234422233233334422233344422233334422333333344422234422333334433344433422333233333333344322333333334443344234222333223333344456555555555555555554554665566555555
-- 090:443322233323333333334432223333333344334443342223332233333442233442223333333442233333444223333442233333433444222442223323343333344332223332333333333444322333333334433444234422233223333344223334422233333344445655455555555555544544665566555555
-- 091:422233333333443344423442223322333334422333444223333334442233333344222333442223333443334422244223332333333334443222333333333433334433222333323334334442244422333233333442223334422233333444223333333442223344445555555555555555555544655565555555
-- 092:422333223333444223334442223333344422333333444222334442233333443334422344223322233333333444322333333333343334443322233332333433444223442223332333344422333344422333334442233333334442223444223333344333444233455555555555555555555546655555555555
-- 093:222333334442233333334442223344222333344433344423442233222333333333443223333333333443334433322233332233333444223444222333333334422233334442223333444223333333344422334422233333443333442334223332233333333344455555555555555555555446655555555555
-- 094:223344422333334443334442334223332233333333344432233333333334433344233222333322333333442223444222333333334422233334442223333444223333333344422234442233333344333344433322333223333333333444222333333333443334445555554554555555555466555555555555
-- 095:334223332233333333334442223333333333443334423342223333223333344422344422233333333444222333344422233333442223333333344422234442233333344333344433322333323333333333344322233333333344333442334222333322333334444555554554555555554466555555555555
-- 096:223333333333443334443342223333223333334422234442223333333344422233334442223333344422333333333444222344222333333443333444233222333223333333333444222333333333344333444234422233322233333442223344422233333334444555555555555555554465555555555555
-- 097:233333233343334422234442223333333334422233334444222333334422233333333444222334442233333344333344423342233322233333333334442223333333333443334442334222333322333334442223444422233333333442223333344422233333444555555555554555554665555555555555
-- 098:233323333344422333334442223333334422233333333444222334442233333344433344422332223332233333333333444222333333333344333344233422233332233333344422234442223333333334442233333444422233334442223333343334442223444455555555554555544665555555555555
-- 099:333333444222333333334442223344422233333444333444423342223332233333333334443222333333333334333344433322233333223334334442223444222333233333444222333334442223333344422233333333444422234442223333334433334442333455555555554555544655555555555555
-- 100:333444223333334433344442234422233322333333333344432223333333333343333344433222233333233344334442224444222333233333344422333334442223333334442223333333344422233344222333333444333444423342223322233333333333444445555555555555546655555555555555
-- 101:442223332333343333344443322233333233333433333444332223333332333443334442244422223332233333344222333344422233333334442223333333344422233344422233333344333444422344222333223333333333444332223333333333343333344445555555555555446655555555555555
-- 102:223333233333333333344432223333333333444333444223442223333222333333442223334442222333333334442223333334444222333344422233333343334444222444222333223334333333444332223333323333333333334443222233333323334433344445554555555555466555555555555555
-- 103:333333333344333344433342223333322333333344422334444222333333333444222333333444222233333444222333333333344422223444222332333443333344443332223333223333333333334443222333333333334443334442334222233322233333344444554555555555466555555555555555
-- 104:333323333433344422244442223333233333344422233334444222233333344422233333333344422223344422233333344433334444233422233322233333333333444422233333333333344433344423342222333322233333344422233444222233323333334444555555555554465555555555555555
-- 105:322333333344422233344442223333333344422233333333444422233334442223333334433334442223442223332223334333333444433222333333333333433333444333222333333323334433344422244442223333233333344422233333444222233333334444555545555554665555556555555555
-- 106:333333444422233333344442223333344442223333334333444422224444222333233344333333444333222233332233333333333344433222333333333334443334442234442223333222333333444222333444422223333333344422233333333444222233334444455545555544665555556655555555
-- 107:333444422233333333344442223334442223333334444333344422334222333322233333333333344432223333333333333443333444333422223333322333333344422223444422223333333333444222333333444422233333344422233333333333444222234444455545555544655555566655555555
-- 108:444222233333344333344442224442223333223333333333344443322233333323333334333333444332222333333323334433344442224444222333322333333444222233334444222233333334442223333333334444222233344422233333334443333444222344455555555546655555566555555555
-- 109:222233333334433333344443333222333322333333333333334442222333333333333444333344423344222233332223333333444222233444422223333333334444222333333344442222333344442223333333433334444222344422233332333343333334444333445555555446655555556555555555
-- 110:233322233333333333344443222333333333333334333334444333222233333322333343334442222444422223333233333334442223333334444222333333344442223333333333444422223344422223333334444333344442233422233332223333333333334444345555455446555555556555555555
-- 111:333233333333333333444332222333333333333444333444223344222233332223333333444222233344442222333333333444422233333333444422223333444422233333334433334444222344422233322233333333333344443322233333323333333333333444445555455466555555555555555555
-- 112:333333334443333444433342222333332223333333344422223444422223333333333344442223333334444222233333334442222333333333344442222234444222333333334433333344442333222233332233333333333333444422223333333333333444333344444555454465555555555555555555
-- 113:333333444333344422244442222333322333333344442223333444422222333333334444222333333333444422223333444422233333334443333444422234442223333223333433333333444433222333333333333334333333444433222223333333233334333344444555554665555555555555555555
-- 114:223333333344422223344442222333333333334444222333333344442222333333344422223333333333344442222334442222333233334443333344442333322233333223333333333333334443222233333333333334443333444223344222233333222333333344444555554665555555555555555555
-- 115:333333344442223333444442222333333333444222233333333344442222233334442222333333344433334444222344422223332223333333333333444433222333333333333333433333344443332222333333323333343333444222244442222233332333333334444455544655555555555555555555
-- 116:333344442222333333444442222333333344422223333333333334444222233444222233333333444333333444423334222333332223333333333333344442222233333333333334444333444423334422223333322233333333444222233344442222333333333334444455546655555555555555555555
-- 117:334442222333333333444442222333344442222333333344433334444222234442223333222333333333333344443322223333333333333334333333444433322223333333323333443333444422244444222233332233333334444222233333444422222333333334444455446655555555555555555555
-- 118:444222233333333333444442222334444222233333333444333334444423334222233332223333333333333334444222223333333333333344433334444233342222233333222233333334444222233444442222333333333334444222233333333444422223333334444445446555555555555555555555
-- 119:222233333333443333444442222444422233332223333433333333444433322223333333333333334333333344443322222333333332333344333344442223444422223333322333333334442222333334444422223333333334444222233333333334444222223333444445466555555555555555555555
-- 120:233333333444433333444442333422223333222233333333333333444442222333333333333333344433334444233342222233333322233333333444422223344442222233333333333344442222333333344444222233333334444222233333334333344444222233444444465555555555555555555555
-- 121:333233333433333333444443332222333333223333333333333333444332222233333333333333444333344442223444222223333222333333334444222233334444422223333333333444422223333333333444442222333334444222233333334443333344442222344444665555555555555555555555
-- 122:222233333333333333444443222233333333333333334433333344443333222223333333223333433334444222234444422222333323333333344442222333333344442222233333333444422223333333333334444422223334444222233333333444333333444442333444665556555555555555555555
-- 123:223333333333333333444432222333333333333333444433334444223344222223333322223333333344442222333444442222233333333333444422223333333334444422222333334444222233333333443333344444222244444222233332333334433333333444433334655556655555555555555555
-- 124:333333343333333444433332222333333333233333443333444422224444422222333322333333333444422223333344444222223333333334444222233333333333344442222233334444222233333333444433333444442233442222333332222333333333333334444435555556655555555555555555
-- 125:333334443333344442333442222333333322233333333344442222334444422222333333333333344442222333333334444422222333333344442222333333333333334444422222344442222333333333344433333334444433332222333333222333333333333333344445555556555555555555555555
-- 126:333444433334444222344442222333332222333333334444222223333444442222233333333333444422223333333333444442222233333444422222333333334433333444442222244442222333322233333333333333344444332222333333332333333334333333344444455555555555555555555555
-- 127:333433333444422223444442222233333233333333444442222333333444442222233333333344442222233333333333344444222223334444222223333333344443333334444422333422223333322223333333333333333444442222333333333333333334443333334444445555555555555555555555
-- 128:333333444442222333444442222233333333333334444222233333333344444222223333333444422223333333334333334444422222344442222233332333334443333333444443333322223333332223333333333333333344443322222333333333333333444433334444445555555555555555555555
-- 129:333344442222233334444442222233333333333444422223333333333344444222223333344444222233333333344433333444442222344422222333322233333433333333334444433222223333333333333333343333333344443332222223333333322333334433334444444555555555555555555555
-- 130:334444222233333334444442222233333333344442222233333333333334444422222333444422222333333333444433333344444223334422223333222223333333333333333444443222233333333333333333344433333444443333422222233333322223333333333444444555555555554455555555
-- 131:444422223333333334444442222233333334444222223333333334333334444422222334444222233333233333444333333334444433333222233333332233333333333333333344443322222333333333333333344443333444442233444222222333332222333333333444444555555555554455555555
-- 132:442222333333333334444442222233333444442222333333333444333334444442222344442222333332223333343333333333444443332222333333333333333333433333333444443332222233333333332333334443333444442222444442222223333322333333333444444455555555544445555555
-- 133:222233333333333334444442222233344444222233333333344444333333444442223334222223333222223333333333333333344444322223333333333333333334444333333444433333422222333333322223333333333444422222334444422222233333333333333444444455555555554455555555
-- 134:223333333334333334444442222234444422222333323333334433333333444444333332222333333322233333333333333333344444322222333333333333333334444333334444422334442222223333322222333333333444422222333344444222222333333333333344444455555555554455555555
-- 135:333333333444333334444442222244442222233333223333334333333333344444333222223333333333333333333433333333444443332222233333333332333333444333344444222234444422222333333223333333333444422222333333444442222223333333333344444445555555555555555555
-- </SCREEN>

-- <PALETTE>
-- 000:0000001c181c3838385d5d5d7d7d7dbababad6d6d6fffffff21018ff55553499ba65eef6b2f6fad67918ffbe3cff00ff
-- </PALETTE>

-- <PALETTE1>
-- 000:0000001c181c3838385d5d5d7d7d7dbababad6d6d6fffffff21018ff55553499ba65eef6b2f6fad67918ffbe3cff00ff
-- </PALETTE1>

