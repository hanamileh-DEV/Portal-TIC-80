-- title:  Portal 3D
-- author: HanamileH, soxfox42
-- desc:   version 1.0 (powered by UniTIC v 1.3)
-- script: lua
-- saveid: portal3d_unitic

-- version: DEV 0.1.5

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
potato_pc=false, --dont
css_content=true, --dont
m_s=80, --mouse sensitivity
r_p=true, --rendering portals
h_q_p=false, --high quality portals
music=true,
sfx=true,
}

save={ --saving the game
i=not pmem(0)~=0, --How for the first time the player went into the game
lvl=pmem(0),
st=pmem(1) --settings (All settings except the sensitivity of the mouse in binary form)
}

if save.st&16~=0 then
	st.r_p  =save.st&1~=0
	st.h_q_p=save.st&2~=0
	st.music=save.st&4~=0
	st.sfx  =save.st&8~=0
end

--camera
local cam = { x = 0, y = 0, z = 0, tx = 0, ty = 0 }
--player
local plr = { x = 95, y = 65, z = 500, tx = 0, ty = 0, vy=0 , xy=false, noclip = false , hp = 100 , hp2 = 100, cd = 0 , cd2 = 0, dt= 1, cd3 = 0}
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
	{--cube
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
	{--cube companion
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
	{ --cube ejector (idk what its called)
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
	{--light bridge (-X +X)
		v={{-48,4,-48},{48,4,-48},{-48,4,48},{48,4,48}},
		f={{1,2,3,uv={{0,232},{16,232},{0,248}},f=3},{2,3,4,uv={{16,232},{0,248},{16,248}},f=3}}
	},
	{--light bridge (-Z +Z)
		v={{-48,4,-48},{-48,4,48},{48,4,-48},{48,4,48}},
		f={{1,2,3,uv={{0,232},{16,232},{0,248}},f=3},{2,3,4,uv={{16,232},{0,248},{16,248}},f=3}}
	},
	{--button -X
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
	{--button +X
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
	{--button -Z
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
	{--button +Z
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
	{ --turret -X
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
	{ --turret +X
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
	{ --turret -Z
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
	{ --turret +Z
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
t1=0,
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
		t={} --turrets
	},
	world={v={},f={},sp={}},
	map={},
	pr={}, --particles
	p={ --portals
		-- list table with following fields:
		-- {x, y, z, plane, normal}
		nil,
		nil,
	},
	lg={--light bridge generators
		--{2,0,0,3,1},
		--{2,0,11,3,2},
		--{0,0,5,1,2},
		--{11,0,5,1,1}
	}
}

--maps
local maps={}

maps[0]={ --main gameroom
	w={ --table for walls
	--{X, Y, Z, angle, face, type}
	},
	o={ --table for objects
	 --{X, Y, Z, type, [additional.parameters (not necessarily)]}
	},
	p={}, --table for portals (leave empty if the portals are not needed)
	lg={} --light bridge generators
}
maps[-1]={ --world from the main menu
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

},
o={},
p={},
lg={}
}
--
for x=0,10 do
	for y=0,2 do
		maps[0].w[#maps[0].w+1]={x,y,0 ,3,1,R(1,2)}
		maps[0].w[#maps[0].w+1]={x,y,11,3,2,R(1,2)}
		maps[0].w[#maps[0].w+1]={0 ,y,x,1,2,R(1,2)}
		maps[0].w[#maps[0].w+1]={11,y,x,1,1,R(1,2)}
	end


	for z=0,10 do
		maps[0].w[#maps[0].w+1]={x,0,z,2,2,1}
		maps[0].w[#maps[0].w+1]={x,3,z,2,1,2}
	end
end

for x=0,5 do
	maps[-1].w[#maps[-1].w+1]={0,0,x,1,2,2}
	maps[-1].w[#maps[-1].w+1]={x,0,6,3,2,2}
	for z=0,5 do
		maps[-1].w[#maps[-1].w+1]={x,0,z,2,2,1}
		maps[-1].w[#maps[-1].w+1]={x,1,z,2,1,2}
	end
end
for x=0,3 do
	maps[-1].w[#maps[-1].w+1]={x,0,0,3,1,2}
end
--
local function addp(x,y,z,vx,vy,vz,lifetime,color) --add particle
	draw.pr[#draw.pr+1]={x=x,y=y,z=z,vx=vx,vy=vy,vz=vz,lt=lifetime,t=0,c=color}
end

local function coll(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4) --collision of two cubes
	-- x1,x2=min(x1,x2),max(x1,x2)
	-- y1,y2=min(y1,y2),max(y1,y2)
	-- z1,z2=min(z1,z2),max(z1,z2)

	-- x3,x4=min(x3,x4),max(x3,x4)
	-- y3,y4=min(y3,y4),max(y3,y4)
	-- z3,z4=min(z3,z4),max(z3,z4)

	return (x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3 and z1 < z4 and z2 > z3)
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

	--quick clipping for portals
	if draw_portal==nil then
		for ind=1,#draw.world.f do unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
	elseif draw_portal==true and p_id==1 then
		if draw.p[2][4]==1 and draw.p[2][5]==1 then

			for ind=1,#draw.world.f do
				if (draw.world.f[ind][1]%world_size[4]%world_size[1]>(draw.p[2][1]+1) or draw.world.f[ind][2]%world_size[4]%world_size[1]>(draw.p[2][1]+1) or draw.world.f[ind][3]%world_size[4]%world_size[1]>(draw.p[2][1]+1))==false and
					(draw.world.f[ind][1]%world_size[4]%world_size[1]~=0 or draw.world.f[ind][2]%world_size[4]%world_size[1]~=0 or draw.world.f[ind][3]%world_size[4]%world_size[1]~=0)
				then unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
			end

		elseif draw.p[2][4]==1 and draw.p[2][5]==2 then

			for ind=1,#draw.world.f do
				if (draw.world.f[ind][1]%world_size[4]%world_size[1]<(draw.p[2][1]+1) or draw.world.f[ind][2]%world_size[4]%world_size[1]<(draw.p[2][1]+1) or draw.world.f[ind][3]%world_size[4]%world_size[1]<(draw.p[2][1]+1))==false or
				(draw.world.f[ind][1]%world_size[4]%world_size[1]==0 or draw.world.f[ind][2]%world_size[4]%world_size[1]==0 or draw.world.f[ind][3]%world_size[4]%world_size[1]==0)
				then unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
			end

		elseif draw.p[2][4]==3 and draw.p[2][5]==1 then

			for ind=1,#draw.world.f do
				if (draw.world.f[ind][1]//world_size[4]%world_size[1]<(draw.p[2][3]) or draw.world.f[ind][2]//world_size[4]%world_size[1]<(draw.p[2][3]) or draw.world.f[ind][3]//world_size[4]%world_size[1]<(draw.p[2][3]))==false
				then unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
			end

		elseif draw.p[2][4]==3 and draw.p[2][5]==2 then

			for ind=1,#draw.world.f do
				if (draw.world.f[ind][1]//world_size[4]%world_size[1]>(draw.p[2][3]) or draw.world.f[ind][2]//world_size[4]%world_size[1]>(draw.p[2][3]) or draw.world.f[ind][3]//world_size[4]%world_size[1]>(draw.p[2][3]))==false
				then unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
			end
		else error()
		end

	elseif draw_portal==true and p_id==2 then
		if draw.p[1][4]==1 and draw.p[1][5]==1 then

			for ind=1,#draw.world.f do
				if (draw.world.f[ind][1]%world_size[4]%world_size[1]>(draw.p[1][1]+1) or draw.world.f[ind][2]%world_size[4]%world_size[1]>(draw.p[1][1]+1) or draw.world.f[ind][3]%world_size[4]%world_size[1]>(draw.p[1][1]+1))==false and
					(draw.world.f[ind][1]%world_size[4]%world_size[1]~=0 or draw.world.f[ind][2]%world_size[4]%world_size[1]~=0 or draw.world.f[ind][3]%world_size[4]%world_size[1]~=0)
				then unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
			end

		elseif draw.p[1][4]==1 and draw.p[1][5]==2 then

			for ind=1,#draw.world.f do
				if (draw.world.f[ind][1]%world_size[4]%world_size[1]<(draw.p[1][1]+1) or draw.world.f[ind][2]%world_size[4]%world_size[1]<(draw.p[1][1]+1) or draw.world.f[ind][3]%world_size[4]%world_size[1]<(draw.p[1][1]+1))==false or
				(draw.world.f[ind][1]%world_size[4]%world_size[1]==0 or draw.world.f[ind][2]%world_size[4]%world_size[1]==0 or draw.world.f[ind][3]%world_size[4]%world_size[1]==0)
				then unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
			end

		elseif draw.p[1][4]==3 and draw.p[1][5]==1 then

			for ind=1,#draw.world.f do
				if (draw.world.f[ind][1]//world_size[4]%world_size[1]<(draw.p[1][3]) or draw.world.f[ind][2]//world_size[4]%world_size[1]<(draw.p[1][3]) or draw.world.f[ind][3]//world_size[4]%world_size[1]<(draw.p[1][3]))==false
				then unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
			end

		elseif draw.p[1][4]==3 and draw.p[1][5]==2 then

			for ind=1,#draw.world.f do
				if (draw.world.f[ind][1]//world_size[4]%world_size[1]>(draw.p[1][3]) or draw.world.f[ind][2]//world_size[4]%world_size[1]>(draw.p[1][3]) or draw.world.f[ind][3]//world_size[4]%world_size[1]>(draw.p[1][3]))==false
				then unitic.poly.f[#unitic.poly.f+1]={draw.world.f[ind][1],draw.world.f[ind][2],draw.world.f[ind][3],f=draw.world.f[ind].f,uv=draw.world.f[ind].uv} end
			end
		else error("unknown data about 1 portal | rotation: "..draw.p[1][4].." normal:"..draw.p[1][5])
		end
	else
		error("unknown function inputs | "..draw_portal.." "..p_id)
	end
	--objects (1)--
	local f1={{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},{3 ,8 ,4 ,uv={{128,128},{125,132},{128,132},-1},f=2},{7 ,6 ,8 ,uv={{128,128},{125,132},{128,132},-1},f=2},{1 ,4 ,2 ,uv={{125,132},{128,128},{125,128},-1},f=2},{6 ,1 ,2 ,uv={{128,132},{125,128},{125,132},-1},f=2},{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},{3 ,7 ,8 ,uv={{128,128},{125,128},{125,132},-1},f=2},{7 ,5 ,6 ,uv={{128,128},{125,128},{125,132},-1},f=2},{1 ,3 ,4 ,uv={{125,132},{128,132},{128,128},-1},f=2},{6 ,5 ,1 ,uv={{128,132},{128,128},{125,128},-1},f=2},{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},}
	local f2={{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},{3 ,8 ,4 ,uv={{128,132},{125,136},{128,136},-1},f=2},{7 ,6 ,8 ,uv={{128,132},{125,136},{128,136},-1},f=2},{1 ,4 ,2 ,uv={{125,136},{128,132},{125,132},-1},f=2},{6 ,1 ,2 ,uv={{128,136},{125,132},{125,136},-1},f=2},{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},{3 ,7 ,8 ,uv={{128,132},{125,132},{125,136},-1},f=2},{7 ,5 ,6 ,uv={{128,132},{125,132},{125,136},-1},f=2},{1 ,3 ,4 ,uv={{125,136},{128,136},{128,132},-1},f=2},{6 ,5 ,1 ,uv={{128,136},{128,132},{125,132},-1},f=2},{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},}
	
	for i=1,#draw.objects.c  do unitic.obj[#unitic.obj+1]=draw.objects.c [i] end
	for i=1,#draw.objects.cd do unitic.obj[#unitic.obj+1]=draw.objects.cd[i] end
	for i=1,#draw.objects.lb do unitic.obj[#unitic.obj+1]=draw.objects.lb[i] end
	for i=1,#draw.objects.b  do
		if draw.objects.b[i].s and draw.objects.b[i].tick then draw.objects.b[i].model.f=f2 elseif draw.objects.b[i].tick then draw.objects.b[i].model.f=f1 end
		unitic.obj[#unitic.obj+1]=draw.objects.b[i]
	end
	for i=1,#draw.objects.t do unitic.obj[#unitic.obj+1]=draw.objects.t[i] end
	--objects (2)--
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
				unitic.poly.f[#unitic.poly.f+1]={unitic.obj[ind1].model.f[ind2][1]+vt, unitic.obj[ind1].model.f[ind2][2]+vt, unitic.obj[ind1].model.f[ind2][3]+vt, f=unitic.obj[ind1].model.f[ind2].f,uv={x={unitic.obj[ind1].model.f[ind2].uv[1][1],unitic.obj[ind1].model.f[ind2].uv[2][1],unitic.obj[ind1].model.f[ind2].uv[3][1]},y={unitic.obj[ind1].model.f[ind2].uv[1][2],unitic.obj[ind1].model.f[ind2].uv[2][2],unitic.obj[ind1].model.f[ind2].uv[3][2]}}}
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
		local tri_face = (p2d.x[2] - p2d.x[1]) * (p2d.y[3] - p2d.y[1]) - (p2d.x[3] - p2d.x[1]) * (p2d.y[2] - p2d.y[1]) < 0

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
			if st.css_content then
				pix(p2d.x, p2d.y, 0)
				print(i, p2d.x, p2d.y, 7)
			else
				print("ERROR", p2d.x, p2d.y+1, 1)
				print("ERROR", p2d.x, p2d.y, 9)
			end
		end
	end
	if #unitic.p~=0 then
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

local wall_coll={[1]=true,[2]=true,[3]=true,[4]=true,[8]=true,[9]=true,[10]=true,[13]=true,[14]=true,[16]=true,[17]=true,[18]=true,[19]=true}
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
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then plr.hp=1 end
		end

		if draw.map[2][x0][y0][z0][2] > 0 and draw.map[2][x0][y0][z0][2]~=5 and draw.map[2][x0][y0][z0][2]~=8 and draw.map[2][x0][y0][z0][2]~=9 then
			if coll(plr.x - 16, ly - 64, lz - 16, plr.x + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then colx = true end
			if coll(lx - 16, plr.y - 64, lz - 16, lx + 16, plr.y + 16, lz + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then coly = true end
			if coll(lx - 16, ly - 64, plr.z - 16, lx + 16, ly + 16, plr.z + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then colz = true end
		elseif draw.map[2][x0][y0][z0][2]==5 then
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then plr.hp=1 sfx(2,"C-3",-1,1) end
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
			if coll(lx - 16, ly - 64, lz - 16, lx + 16, ly + 16, lz + 16, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then plr.hp=1 sfx(2,"C-3",-1,1) end
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

function unitic.cube_update() --all physics related to cubes
	local i=0 if #draw.objects.c~=0 then
		repeat
			i=i+1
			local clx=draw.objects.c[i].x
			local cly=draw.objects.c[i].y
			local clz=draw.objects.c[i].z
			--changing the position of the cube here
			draw.objects.c[i].y=draw.objects.c[i].y+draw.objects.c[i].vy
			draw.objects.c[i].vy=max(draw.objects.c[i].vy-0.5,-20)
			--
			local cx=draw.objects.c[i].x
			local cy=draw.objects.c[i].y
			local cz=draw.objects.c[i].z

			local colx = false
			local coly = false
			local colz = false

			local inbp = false --is the cube in the blue portal
			local inop = false --is the cube in the orange portal
			local bf   = false --is the cube in the blue field
			
			local x1=max((cx-25)//96,0) -- +-24
			local y1=max((cy-25)//128,0)
			local z1=max((cz-25)//96,0)
		
			local x2=min((cx+25)//96,world_size[1]-1)
			local y2=min((cy+25)//128,world_size[2]-1)
			local z2=min((cz+25)//96,world_size[3]-1)
			
			for x0 = x1,x2 do for y0 = y1,y2 do for z0 = z1,z2 do
				if wall_coll[draw.map[1][x0][y0][z0][2]] then
					if coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colx = true end
					if coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then coly = true end
					if coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colz = true end
				elseif draw.map[1][x0][y0][z0][2]==5 or draw.map[1][x0][y0][z0][2]==6 then
					if not draw.p[1] or not draw.p[2] then
						if coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colx = true end
						if coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then coly = true end
						if coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colz = true end
					else
						if draw.map[1][x0][y0][z0][2]==5 and coll( clx - 24, cly - 24, clz - 24,  clx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then inbp=true end
						if draw.map[1][x0][y0][z0][2]==6 and coll( clx - 24, cly - 24, clz - 24,  clx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then inop=true end

						if coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 2)
						or coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 94, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
						or coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96, y0 * 128 + 126, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colx = true end
		
						if coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 2)
						or coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 94, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
						or coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96, y0 * 128 + 126, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then coly = true end
		
						if coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24, cz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 2)
						or coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24, cz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 94, x0 * 96, y0 * 128 + 126, z0 * 96 + 94)
						or coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24, cz + 24, x0 * 96, y0 * 128 + 126, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then colz = true end
					end
				elseif draw.map[1][x0][y0][z0][2]==7 then
					if coll(clx - 24,  cly - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96, y0 * 128 + 2, z0 * 96 + 2, x0 * 96, y0 * 128 + 126, z0 * 96 + 94) then bf = true end
				end
		
				if draw.map[2][x0][y0][z0][2] > 0 and draw.map[2][x0][y0][z0][2]~=5 and draw.map[2][x0][y0][z0][2]~=8 and draw.map[2][x0][y0][z0][2]~=9 then
					if coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then colx = true end
					if coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then coly = true end
					if coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then colz = true end
				elseif draw.map[2][x0][y0][z0][2]==8 or draw.map[2][x0][y0][z0][2]==9 then
					if coll(clx - 24, cly - 24, clz - 24, clx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128, z0 * 96 + 2, x0 * 96 + 94, y0 * 128, z0 * 96 + 94) then draw.objects.c[i].vy=12 sfx(0,"C-6",-1,1) end
				end
		
				if wall_coll[draw.map[3][x0][y0][z0][2]] then
					if coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colx = true end
					if coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then coly = true end
					if coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colz = true end
				elseif draw.map[3][x0][y0][z0][2]==5 or draw.map[3][x0][y0][z0][2]==6 then
					if not draw.p[1] or not draw.p[2] then
						if coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colx = true end
						if coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then coly = true end
						if coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colz = true end
					else
						if draw.map[3][x0][y0][z0][2]==5 and coll( clx - 24, cly - 24, clz - 24,  clx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96) then inbp=true end
						if draw.map[3][x0][y0][z0][2]==6 and coll( clx - 24, cly - 24, clz - 24,  clx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96) then inop=true end

						if coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96)
						or coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96 + 94, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
						or coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 126, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colx = true end
		
						if coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96)
						or coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96 + 94, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
						or coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 126, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then coly = true end
		
						if coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24, cz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 2, y0 * 128 + 126, z0 * 96)
						or coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24, cz + 24, x0 * 96 + 94, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96)
						or coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24, cz + 24, x0 * 96 + 2, y0 * 128 + 126, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then colz = true end
					end
				elseif draw.map[3][x0][y0][z0][2]==7 then
					if coll(clx - 24, cly - 24, clz - 24, clx + 24, cly + 24, clz + 24, x0 * 96 + 2, y0 * 128 + 2, z0 * 96, x0 * 96 + 94, y0 * 128 + 126, z0 * 96) then bf=true end
				end

			end end end
			--collision with the player
			local x0=plr.x
			local y0=plr.y
			local z0=plr.z
			if not coll(clx - 24, cly - 24, clz - 24,  clx + 24,cly + 24, clz + 24, x0 - 16, y0 - 64, z0 - 16, x0 + 16, y0 + 16, z0 + 16) then
				if  coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 - 16, y0 - 64, z0 - 16, x0 + 16, y0 + 16, z0 + 16) then colx = true end
				if  coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 - 16, y0 - 64, z0 - 16, x0 + 16, y0 + 16, z0 + 16) then coly = true end
				if  coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 - 16, y0 - 64, z0 - 16, x0 + 16, y0 + 16, z0 + 16) then colz = true end
			end

			--collision with objects
			for i2=1,#draw.objects.c do
				if i2~=i then
					local x0=draw.objects.c[i2].x
					local y0=draw.objects.c[i2].y
					local z0=draw.objects.c[i2].z
					if not coll(clx - 24, cly - 24, clz - 24, clx + 24, cly + 24, clz + 24, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then
						if  coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then colx = true end
						if  coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then coly = true end
						if  coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 - 24, y0 - 24, z0 - 24, x0 + 24, y0 + 24, z0 + 24) then colz = true end
					end
				end
			end

			for i2=1,#draw.objects.lb do
				local x0=draw.objects.lb[i2].x
				local y0=draw.objects.lb[i2].y
				local z0=draw.objects.lb[i2].z
				if not coll(clx - 24, cly - 24, clz - 24, clx + 24, cly + 24, clz + 24, x0 - 48, y0, z0 - 48, x0 + 48, y0, z0 + 48) then
					if  coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 - 48, y0, z0 - 48, x0 + 48, y0, z0 + 48) then colx = true end
					if  coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 - 48, y0, z0 - 48, x0 + 48, y0, z0 + 48) then coly = true end
					if  coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 - 48, y0, z0 - 48, x0 + 48, y0, z0 + 48) then colz = true end
				end
			end

			for i2=1,#draw.objects.b do
				local x0=draw.objects.b[i2].x
				local y0=draw.objects.b[i2].y
				local z0=draw.objects.b[i2].z
				if not coll(clx - 24, cly - 24, clz - 24, clx + 24, cly + 24, clz + 24, x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6) then
					if  coll( cx - 24, cly - 24, clz - 24,  cx + 24, cly + 24, clz + 24, x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6) then colx = true end
					if  coll(clx - 24,  cy - 24, clz - 24, clx + 24,  cy + 24, clz + 24, x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6) then coly = true end
					if  coll(clx - 24, cly - 24,  cz - 24, clx + 24, cly + 24,  cz + 24, x0 - 6, y0, z0 - 6, x0 + 6, y0 + 52, z0 + 6) then colz = true end
				end
			end

			--
			if colx then draw.objects.c[i].x=clx end
			if coly then draw.objects.c[i].y=cly draw.objects.c[i].vy=0 end
			if colz then draw.objects.c[i].z=clz end

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

function unitic.render()
	cam.x, cam.y, cam.z, cam.tx, cam.ty = plr.x, plr.y, plr.z, plr.tx, plr.ty

	local dist1, dist2, dist = math.huge, math.huge, false
	if draw.p[1] then
		local x1, y1, z1 = portalcenter(1)
		dist1=((x1*96-plr.x)^2+(y1*128-plr.y)^2+(z1*96-plr.z)^2)
	end
	if draw.p[2] then
		local x2, y2, z2 = portalcenter(2)
		dist2=((x2*96-plr.x)^2+(y2*128-plr.y)^2+(z2*96-plr.z)^2)
		dist = true
	end
	if draw.p[1] and draw.p[2] then
		dist=dist1 < dist2
	end

	vbank(1)
		if not st.potato_pc or R()<0.05 then cls(1) end
		unitic.update_pr()
		unitic.update()
		unitic.draw()
		if draw.p[1] or draw.p[2] then
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
			for i=1,#v_id do
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
	vbank(0)
	cls(1)

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
				memcpy(0x8000,0x0,240*136/2)
			else
				memcpy(0x0,0x8000,240*136/2)
			end
	end
end

local function raycast(x1,y1,z1, x2,y2,z2, hitwalls,hitflats) -- walk along a segment, checking whether it collides with the walls
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
			end
			if hitwalls[draw.map[1][x + ox][y][z][2]] then
				return x + ox, y, z, 1
			end
			if x < 0 then
				return
			end
		elseif ty < tz then
			y, ty = y + sy, ty + ly
			if (y + oy) * sy > y2 * sy or (y + oy) < 0 or (y + oy) > world_size[2] - 1 then
				return
			end
			if hitflats[draw.map[2][x][y + oy][z][2]] then
				return x, y + oy, z, 2
			end
			if y < 0 then
				return
			end
		else
			z, tz = z + sz, tz + lz
			if (z + oz) * sz > z2 * sz or (z + oz) < 0 or (z + oz) > world_size[3] - 1 then
				return
			end
			if hitwalls[draw.map[3][x][y][z + oz][2]] then
				return x, y, z + oz, 3
			end
			if z < 0 then
				return
			end
		end
	end
end

function unitic.turret_update()
	for i=1,#draw.objects.t do
		local t_ang=0
		if     draw.objects.t[i].type==10 then t_ang=pi2
		elseif draw.objects.t[i].type==11 then t_ang=-pi2
		elseif draw.objects.t[i].type==12 then t_ang=0
		elseif draw.objects.t[i].type==13 then t_ang=-math.pi end

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
					if draw.objects.t[i].type==12 or draw.objects.t[i].type==13 then
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
	local f1={{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},{3 ,8 ,4 ,uv={{128,128},{125,132},{128,132},-1},f=2},{7 ,6 ,8 ,uv={{128,128},{125,132},{128,132},-1},f=2},{1 ,4 ,2 ,uv={{125,132},{128,128},{125,128},-1},f=2},{6 ,1 ,2 ,uv={{128,132},{125,128},{125,132},-1},f=2},{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},{3 ,7 ,8 ,uv={{128,128},{125,128},{125,132},-1},f=2},{7 ,5 ,6 ,uv={{128,128},{125,128},{125,132},-1},f=2},{1 ,3 ,4 ,uv={{125,132},{128,132},{128,128},-1},f=2},{6 ,5 ,1 ,uv={{128,132},{128,128},{125,128},-1},f=2},{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},}
	local f2={{5 ,3 ,1 ,uv={{125,136},{120,133},{120,136},-1},f=2},{3 ,8 ,4 ,uv={{128,132},{125,136},{128,136},-1},f=2},{7 ,6 ,8 ,uv={{128,132},{125,136},{128,136},-1},f=2},{1 ,4 ,2 ,uv={{125,136},{128,132},{125,132},-1},f=2},{6 ,1 ,2 ,uv={{128,136},{125,132},{125,136},-1},f=2},{10,11,12,uv={{125,133},{120,128},{120,133},-1},f=3},{5 ,7 ,3 ,uv={{125,136},{125,133},{120,133},-1},f=2},{3 ,7 ,8 ,uv={{128,132},{125,132},{125,136},-1},f=2},{7 ,5 ,6 ,uv={{128,132},{125,132},{125,136},-1},f=2},{1 ,3 ,4 ,uv={{125,136},{128,136},{128,132},-1},f=2},{6 ,5 ,1 ,uv={{128,136},{128,132},{125,132},-1},f=2},{10,9 ,11,uv={{125,133},{125,128},{120,128},-1},f=3},}
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
	if type==1 or type==2 then
		draw.objects.c[#draw.objects.c+1]=
		{type=type, --type
		x=x,y=y,z=z, --object coordinates
		vy=0, --velocity
		draw=true, --whether to display the model
		model=model[type]}
	elseif type==3 then
		draw.objects.cd[#draw.objects.cd+1]=
		{type=type,
		x=x,y=y,z=z,
		draw=true,
		model=model[type]}
	elseif type==4 or type==5 then
		draw.objects.lb[#draw.objects.lb+1]=
		{type=type,
		x=x,y=y,z=z,
		draw=true,
		model=model[type]}
	elseif type==6 or type==7 or type==8 or type==9 then
		draw.objects.b[#draw.objects.b+1]=
		{type=type,
		x=x,y=y,z=z,
		t=t1 or (math.huge), --button press time (math.huge for a constant signal, -1 to switch the signal)
		t1=0,
		tick=false, --sends a signal 1 tick long while pressing the button
		s=false, --button signal
		draw=true,model={v=model[type].v,f=model[type].f}}
	elseif type==10 or type==11 or type==12 or type==13 then
		draw.objects.t[#draw.objects.t+1]=
		{type=type,
		x=x,y=y,z=z,
		cd=0,
		draw=true,model=model[type]}
	elseif type<=#model and type>0 then error("unknown object | "..type) else error("unknown type | "..type) end
end

function update_world()
	draw.world.f={}
	for angle=1,4 do for x0=0,world_size[1]-1 do for y0=0,world_size[2]-1 do for z0=0,world_size[3]-1 do
		local face = draw.map[angle][x0][y0][z0][1]
		local type = draw.map[angle][x0][y0][z0][2]-1

		local type1 = type%5
		local type2 = type//5
		------
		if type~=-1 then
			if angle==1 then
				table.insert(draw.world.f,{x0+y0*world_size[3]+z0*world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+1,f=face,uv={x={24+type1*24,type1*24,24+type1*24},y={32+type2*32,32+type2*32,0+type2*32}}})
				table.insert(draw.world.f,{x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+world_size[3]+1,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+1,f=face,uv={x={type1*24,type1*24,24+type1*24},y={32+type2*32,0+type2*32,0+type2*32}}})
			end

			if angle==2 then
				table.insert(draw.world.f,{x0+y0*world_size[3]+z0*world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+1,f=face,uv={x={0+type1*24,0+type1*24,24+type1*24},y={152+type2*24,176+type2*24,152+type2*24}}})
				table.insert(draw.world.f,{x0+y0*world_size[3]+z0*world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[4]+1,f=face,uv={x={0+type1*24,24+type1*24,24+type1*24},y={176+type2*24,176+type2*24,152+type2*24}}})
			end

			if angle==3 then
				table.insert(draw.world.f,{x0+y0*world_size[3]+z0*world_size[4]+1,x0+y0*world_size[3]+z0*world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+1,f=face,uv={x={24+type1*24,type1*24,24+type1*24},y={32+type2*32,32+type2*32,0+type2*32}}})
				table.insert(draw.world.f,{x0+y0*world_size[3]+z0*world_size[4]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+2,x0+y0*world_size[3]+z0*world_size[4]+world_size[3]+1,f=face,uv={x={type1*24,type1*24,24+type1*24},y={32+type2*32,0+type2*32,0+type2*32}}})
			end

			if face == 2 and (angle == 1 or angle == 3) then
				local idx = #draw.world.f
				for i = 1, 3 do
					draw.world.f[idx - 1].uv.x[i] = (2 * type1 + 1) * 24 - draw.world.f[idx - 1].uv.x[i]
					draw.world.f[idx].uv.x[i] = (2 * type1 + 1) * 24 - draw.world.f[idx].uv.x[i]
				end
			end
		end
		------
	end end end end
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
			--trace("----------------------------------",15)
			for _=1,100 do --bridge lenght limiter
				if vx==-1 or vx==1 then addobj(48+lx*96,ly*128,48+lz*96,4) else addobj(48+lx*96,ly*128,48+lz*96,5) end
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
				if lx<0 or lx>world_size[1]-1 or lz<0 or lz>world_size[3]-1 then break end
				if not (bp or op) then
				if     vx==1  and draw.map[1][lx  ][ly][lz  ][2]~=0 and draw.map[1][lx  ][ly][lz  ][2]~=3 and draw.map[1][lx  ][ly][lz  ][2]~=15 then break
				elseif vx==-1 and draw.map[1][lx+1][ly][lz  ][2]~=0 and draw.map[1][lx+1][ly][lz  ][2]~=3 and draw.map[1][lx+1][ly][lz  ][2]~=15 then break
				elseif vz==1  and draw.map[3][lx  ][ly][lz  ][2]~=0 and draw.map[3][lx  ][ly][lz  ][2]~=3 and draw.map[3][lx  ][ly][lz  ][2]~=15 then break
				elseif vz==-1 and draw.map[3][lx  ][ly][lz+1][2]~=0 and draw.map[3][lx  ][ly][lz+1][2]~=3 and draw.map[3][lx  ][ly][lz+1][2]~=15 then break
				end end
			end
		end
	end
end

local function load_world(world_id) --Loads the world from ROM memory (from the 'Maps' table)
	--init
	draw.map={}
	draw.world={v={},f={},sp={}}
	draw.p={nil,nil}
	draw.pr={}
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
	if maps[world_id]==nil then
		error("Unknown ID in the world | "..world_id)
	end
	----
	for i=1,#maps[world_id].w do
		addwall(maps[world_id].w[i][1],maps[world_id].w[i][2],maps[world_id].w[i][3],maps[world_id].w[i][4],maps[world_id].w[i][5],maps[world_id].w[i][6])
	end
	for i=1,#maps[world_id].o do
		addobj(maps[world_id].o[i][1],maps[world_id].o[i][2],maps[world_id].o[i][3],maps[world_id].o[i][4],maps[world_id].o[i][5])
	end
	for i=1,#maps[world_id].lg do
		draw.lg[i]=maps[world_id].lg[i]
	end

	if maps[world_id].p then
		draw.p=maps[world_id].p
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

--css content
if not st.css_content then
	pal="0000000000003838385d5d5d7d7d7dbababad6d6d6ffffffff00ffff00003499ba65eef6b2f6fad67918ffbe3cff00ff"
	for i=0,511 do
		for i2=0,63 do
			if peek4(0x8000+i*64+i2)~=0 and peek4(0x8000+i*64+i2)~=15 then
			poke4(0x8000+i*64+i2,peek4(0x8000+512*64*0+64*511+i2)) end
		end
	end
	for i=1,20 do
	draw.world.sp[i]={R(0,world_size[1]*96),R(0,world_size[2]*128),R(0,world_size[3]*96)}
	end
end

local fps_={t1=0,t2=0,t3=0,t4=0}
local avf={} --average frame
local fr={0,0,0} --framerate
t1=0
t2=0
t=0
local speed=4

--init
local tm1,tm2 = 0,0
local p={t=0,t1=0,t2=0,t3=0,t4=0} --pause
local ls={t=0,pr=0} --loading screen
local l_={t=0} --logo
local ms={t=0,t1=1,t2=1,t3=1,t4=1,t5=1,t6=1} --main screen
load_world(-1)
--poke(0x7FC3F,1,1)

local open="logo" sync(1,1,false)

function TIC()
	--fps counter
	t1 = time()
	t = t + 1
	--mouse
	local mx, my, cl1, _, cl2 = mouse()
	local cid=0

	if cl1 then tm1 = tm1 + 1 else tm1 = 0 end
	if cl2 then tm2 = tm2 + 1 else tm2 = 0 end

	clp1 = tm1 == 1
	clp2 = tm2 == 1
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
		if l_.t>=90 or (keyp() and l_.t>10) then sync(1,0,false) load_world(-1) open="main" music(2) end
	end
	--------------------------
	-- main screen -----------
	--------------------------
	if open=="main" or open=="main|newgame" or open=="main|authors" or open=="main|settings" then
		ms.t=ms.t+1 --40 96 525
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
		spr(256,min(-104+ms.t*6,8),4,0,1,0,0,13,3)
		if open=="main" then
			if not save.i then print("Continue"  ,min(ms.t*2-10,4)+(1-ms.t1)*20, 45,7) end
			print("New game"  ,min(ms.t*2-20,4)+(1-ms.t2)*20, 55,7)
			print("Skill test",min(ms.t*2-30,4)+(1-ms.t3)*20, 75,7)
			print("Settings"  ,min(ms.t*2-40,4)+(1-ms.t4)*20, 95,7)
			print("Authors"   ,min(ms.t*2-50,4)+(1-ms.t5)*20,105,7)
			print("Exit"      ,min(ms.t*2-60,4)+(1-ms.t6)*20,125,7)
			vbank(0)
			--buttons
 			if my>44  and my<55  and not save.i then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then open="load lvl" end else ms.t1=min(1,ms.t1+0.05) end

			if my>54  and my<65  then cid=1 ms.t2=max(ms.t2-0.05,0.5) if clp1 then if save.i then open="load lvl" music() else open="main|newgame" sfx(16) ms.t1=1 ms.t2=1 end end else ms.t2=min(1,ms.t2+0.05) end

			if my>74  and my<85  then cid=1 ms.t3=max(ms.t3-0.05,0.5) else ms.t3=min(1,ms.t3+0.05) end
			if my>94  and my<105 then cid=1 ms.t4=max(ms.t4-0.05,0.5) if clp1 then open="main|settings" sfx(16) ms.t1=1 end else ms.t4=min(1,ms.t4+0.05) end
			if my>104 and my<115 then cid=1 ms.t5=max(ms.t5-0.05,0.5) if clp1 then open="main|authors" sfx(16) ms.t1=1 end else ms.t5=min(1,ms.t5+0.05) end
			if my>124 and my<135 then cid=1 ms.t6=max(ms.t6-0.05,0.5) if clp1 then exit() end else ms.t6=min(1,ms.t6+0.05) end
		elseif open=="main|newgame" then
			print("Warning",4,35,8)
			print("Your current conservation",4,45,7)
			print("will be removed.",4,55,7)
			print("Continue?",4,65,7)

			print("Accept",4+(1-ms.t1)*20,85,7)
			print("Cancel",4+(1-ms.t2)*20,105,7) 
			if my>84  and my<95  then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then open="load lvl" save.lvl=0 end else ms.t1=min(1,ms.t1+0.05) end
			if my>104 and my<115 then cid=1 ms.t2=max(ms.t2-0.05,0.5) if clp1 then sfx(17) open="main" ms.t1=1 ms.t2=1 ms.t3=1 ms.t4=1 ms.t5=1 ms.t6=1 end else ms.t2=min(1,ms.t2+0.05) end
		elseif open=="main|authors" then
			print("3D engine: UniTIC v 1.3 (MIT license)"   ,1,45,7)
			print("Author of the engine: HanamileH"         ,1,55,7)
			print("Coders:             HanamileH & Soxfox42",1,75,7)
			print("Level designers: [Random dude]"          ,1,85,7)
			print("Testers:            [Random dude]"       ,1,95,7)
			print("Back",4+(1-ms.t1)*20,115,7)
			if my>114 and my<125 then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then sfx(17) open="main" ms.t1=1 ms.t2=1 ms.t3=1 ms.t4=1 ms.t5=1 ms.t6=1 end else ms.t1=min(1,ms.t1+0.05) end
		elseif open=="main|settings" then
			print("Mouse sensevity: "..F(st.m_s),4,35,7)
			print("Music: "                  ,4,55,7)
			print("Sfx: "                    ,4,65,7)
			print("Rendering portals: "      ,4,75,7)
			print("High quality portals: "   ,4,85,7)
			print("Calibration"              ,4,105,7)
			print("Back"                     ,4,125,7)
			--on / off
			if st.music then print("On",117,55,13) else print("Off",117,55,11) end
			if st.sfx   then print("On",117,65,13) else print("Off",117,65,11) end
			if st.r_p   then print("On",117,75,13) else print("Off",117,75,11) end
			if st.h_q_p then print("On",117,85,13) else print("Off",117,85,11) end

			--buttons
			if my>54  and my<64  then cid=1 ms.t1=max(ms.t1-0.05,0.5) if clp1 then sfx(18) music(2) st.music=not st.music end else ms.t1=min(1,ms.t1+0.05) end
			if my>64  and my<74  then cid=1 ms.t2=max(ms.t2-0.05,0.5) if clp1 then sfx(18) st.sfx  =not st.sfx   end else ms.t2=min(1,ms.t2+0.05) end
			if my>74  and my<84  then cid=1 ms.t3=max(ms.t3-0.05,0.5) if clp1 then sfx(18) st.r_p  =not st.r_p   end else ms.t3=min(1,ms.t3+0.05) end
			if my>84  and my<94  then cid=1 ms.t4=max(ms.t4-0.05,0.5) if clp1 then sfx(18) st.h_q_p=not st.h_q_p end else ms.t4=min(1,ms.t4+0.05) end
			if my>104 and my<114 then cid=1 ms.t5=max(ms.t5-0.05,0.5) if clp1 then sfx(16) --[[coming soon]] end else ms.t5=min(1,ms.t5+0.05) end
			if my>124 and my<134 then cid=1 ms.t6=max(ms.t6-0.05,0.5) if clp1 then sfx(17) open="main" ms.t1=1 ms.t2=1 ms.t3=1 ms.t4=1 ms.t5=1 ms.t6=1 end else ms.t6=min(1,ms.t6+0.05) end
			--saving the settings
			save.st=0
			if st.r_p   then save.st=save.st+1 end
			if st.h_q_p then save.st=save.st+2 end
			if st.music then save.st=save.st+4 end
			if st.sfx   then save.st=save.st+8 end
			save.st=save.st+16
			pmem(1,save.st)
		end
	end
	--trace(mx.." "..my,12)
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
		if save.lvl==0 then save.lvl=1 end
		save.lvl=0
		pmem(0,save.lvl)
		load_world(save.lvl)
		poke(0x7FC3F,1,1)
		open="game"
	end
	--------------------------
	-- pause -----------------
	--------------------------
	if open=="pause" then
		p.t=p.t+1
		--GUI
		vbank(0)
		memcpy(0x0,0x8000,240*136/2)
		vbank(1)
		cls(0)
		--logo
		spr(256,min(-104+p.t*6,8),4,0,1,0,0,13,3)
		--text
		print("Pause",min(p.t*2,37),30,7)

		print("Resume"       ,1+p.t1/2,50,7)
		print("Restart level",1+p.t2/2,59,7)
		print("Settings"     ,1+p.t3/2,79,7)
		print("Exit"         ,1+p.t4/2,119,7)
		--buttons
		if my>46 and my<57 then p.t1=min(p.t1+2,20) cid=1 if clp1 then open="game" poke(0x7FC3F,1,1) music(0) end else p.t1=max(p.t1-1,0) end
		if my>56 and my<67 then p.t2=min(p.t2+2,20) cid=1 else p.t2=max(p.t2-1,0) end
		if my>76 and my<87 then p.t3=min(p.t3+2,20) cid=1 if clp1 then open="pause|settings"                  end else p.t3=max(p.t3-1,0) end
		if my>116 and my<127 then p.t4=min(p.t4+2,20) cid=1 if clp1 then exit() end else p.t4=max(p.t4-1,0) end
		--Resume button
		if keyp(44) and p.t>1 then open="game" poke(0x7FC3F,1,1) music(0) end
	end
	--------------------------
	-- pause|settings --------
	--------------------------
	if open=="pause|settings" then
		p.t=p.t+1
		--GUI
		vbank(0)
		memcpy(0x0,0x8000,240*136/2)
		vbank(1)
		cls(0)
		--logo
		spr(256,min(-104+p.t*6,8),4,0,1,0,0,13,3)
		--text
		print("Pause",min(p.t*2,37),30,7)

		print("Resume"       ,1+p.t1/2,50,7)
		print("Restart level",1+p.t2/2,59,7)
		print("Settings"     ,1+p.t3/2,79,7)
		print("Exit"         ,1+p.t4/2,119,7)
		--buttons
		if my>46 and my<57 then p.t1=min(p.t1+2,20) cid=1 if clp1 then open="game" poke(0x7FC3F,1,1) music(0) end else p.t1=max(p.t1-1,0) end
		if my>56 and my<67 then p.t2=min(p.t2+2,20) cid=1 else p.t2=max(p.t2-1,0) end
		if my>76 and my<87 then p.t3=min(p.t3+2,20) cid=1 else p.t3=max(p.t3-1,0) end
		if my>116 and my<127 then p.t4=min(p.t4+2,20) cid=1 if clp1 then exit() end else p.t4=max(p.t4-1,0) end
		--Resume button
		if keyp(44) and p.t>1 then open="game" poke(0x7FC3F,1,1) music(0) end
	end
	--------------------------
	-- game ------------------
	--------------------------
	if open=="game" then
		fps_.t1=time()
		plr.cd2=max(plr.cd2-1,0)
		plr.cd3=max(plr.cd3-1,0)
	 --W A S D
		lx, ly, lz = plr.x, plr.y, plr.z
		if plr.cd3==0 or R()>0.05 then
			if key(23) then plr.z = plr.z - math.cos(plr.ty) * speed plr.x = plr.x - math.sin(plr.ty) * speed end
			if key(19) then plr.z = plr.z + math.cos(plr.ty) * speed plr.x = plr.x + math.sin(plr.ty) * speed end
			if key(1) then plr.z = plr.z - math.cos(plr.ty - pi2) * speed plr.x = plr.x - math.sin(plr.ty - pi2) * speed end
			if key(4) then plr.z = plr.z + math.cos(plr.ty - pi2) * speed plr.x = plr.x + math.sin(plr.ty - pi2) * speed end
		end

		if plr.cd3==0 and key(64) then speed = 8 else speed = 4 end
		if plr.noclip then speed=12 end
		if keyp(57) or keyp(22) then plr.noclip = not plr.noclip end
	 --jump
		if plr.noclip then
			if key(48) then plr.y = plr.y + 8 end
			if key(63) then plr.y = plr.y - 8 end
			plr.vy=0
		else
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
		end
	 --camera rotation
	 	if p.t==0 then
			plr.tx = plr.tx + my/st.m_s
			plr.ty = plr.ty + mx/st.m_s
	 	end
		plr.ty = plr.ty%(math.pi*2)
		plr.tx = max(min(plr.tx, pi2), -pi2)
	 --update + collision
		fps_.t2=time()
		unitic.player_collision()
		unitic.portal_collision()
		unitic.cube_update()
		unitic.button_update()
		unitic.turret_update()
		fps_.t3=time()
	 --scripts
		-- for i=1,5 do
		-- 	if draw.objects.b[i].tick then
		-- 		if draw.objects.b[i].s then addwall(0,0,i-1,1,2,19) else addwall(0,0,i-1,1,2,18) end
		-- 		update_world()
		-- 	end
		-- end
		--if t%30==0 then addobj(1010,180,560,2) end
	 --render
		unitic.render()
		fps_.t4=time()
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
		--if plr.hp<=0 then exit() trace("died :p",2) end

		plr.hp2 = plr.hp
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
				"Collision:"..F(fps_.t3-fps_.t2).." ms. render:"..F(fps_.t4-fps_.t3).." ms. other:"..F(fps_.t2-fps_.t1).." ms. "
			},
			{
				"v: " .. #unitic.poly.v .. " f:" .. #unitic.poly.f .." sp:" .. #unitic.poly.sp.." p:" .. #unitic.p.." | objects:"..#unitic.obj,
				#draw.objects.c.." "..#draw.objects.cd.." "..#draw.objects.lb.." "..#draw.objects.b,
				"camera X:" .. F(plr.x) .. " Y:" .. F(plr.y) .. " Z:" .. F(plr.z),
			}
		}
		if keyp(49) then plr.dt=plr.dt%#debug_text+1 end
		
		vbank(1) do
			for i=1,#debug_text[plr.dt] do
				local text_size=print(debug_text[plr.dt][i], 240,0)
				rect(0,7*(i-1),text_size+2,8,2)
				print(debug_text[plr.dt][i], 1, 2+7*(i-1), 1)
				print(debug_text[plr.dt][i], 1, 1+7*(i-1), 7)
			end

			print("HP: "..plr.hp,1,130,7)

			if plr.noclip then print("Noclip", 104, 85, 7) end
			if not st.css_content then
				rect(116,0,140,7,14)
				print("!",117,1,7*((time()/500)//1%2),false,1,true)
				print("Something is creating script errors",120,1,7,false,1,true)
			end
		vbank(0) end
	end
	--settings
	if not st.sfx then sfx(-1) sfx(-1,0,1) end
	if not st.music then music(-1) end
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
	if open=="pause" then vbank(1)poke(0x03FF9,0)vbank(0)poke(0x03FF9,0)
		if scn_y==0 or scn_y==67 or scn_y==87 or scn_y==127 then
			respal()
			darkpal(max(1-p.t/30,0.4))
		end
		if scn_y==47 then
			respal()
			darkpal(max(1-p.t/30,0.4))
			darkpal(1-p.t1/35)
		end
		if scn_y==57 then
			respal()
			darkpal(max(1-p.t/30,0.4))
			darkpal(1-p.t2/35)
		end
		if scn_y==77 then
			respal()
			darkpal(max(1-p.t/30,0.4))
			darkpal(1-p.t3/35)
		end
		if scn_y==117 then
			respal()
			darkpal(max(1-p.t/30,0.4))
			darkpal(1-p.t4/35)
		end
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

	if open=="main|authors" then
		if scn_y==0 or scn_y==123 then
			respal()
			darkpal(0.2)
		end
		if scn_y==113 then
			darkpal(ms.t1)
		end
	end

	if open=="main|settings" then
		if scn_y==0 or scn_y==63 or scn_y==73 or scn_y==83 or scn_y==93 or scn_y==113 or scn_y==133 then
			respal()
			darkpal(0.2)
		end
		if scn_y==53  then darkpal(ms.t1) end
		if scn_y==63  then darkpal(ms.t2) end
		if scn_y==73  then darkpal(ms.t3) end
		if scn_y==83  then darkpal(ms.t4) end
		if scn_y==103 then darkpal(ms.t5) end
		if scn_y==123 then darkpal(ms.t6) end
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
-- 085:ffffffffffffffffffbbbfffffffffffffffffffaaffffffffffffffffffffff
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
-- 115:fffffffffffffffffffffffffffffffffffffffffffaaaffffffffffffffffff
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
-- 158:ffffffffffffffffff999fffffffffffffffffff88ffffffffffffffffffffff
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
-- 175:afff000dafff000dafff000dafff000da000fffda000fffda000fffda000fffd
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
-- 188:fffffffffffffffffffffffffffffffffffffffffff888ffffffffffffffffff
-- 189:ffffffffffffffffffffff88fffffffff999ffffffffffffffffffffffffffff
-- 190:ffffffffffffffff8ffffffffffffffffffffffff999ffffffffffffffffffff
-- 191:afff000dafff000dafff000dafff000da000fffda000fffda000fffda000fffd
-- 192:555555555ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa5ccccccc
-- 193:55555555ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaacccccccc
-- 194:55555555ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaacccccccc
-- 195:55555555ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaacccccccc
-- 196:55555555ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaacccccccc
-- 197:55555555ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4ccccccc4
-- 198:6666666665555555656555556555555565555655655555556565556565555553
-- 199:6666666655555555655565555555555556555556555555555555555533333333
-- 200:6666666555555554655565545555555455565454555555545555555433555554
-- 201:6666666665555555656555556555555565555655655555556565556565555553
-- 202:6666666655555555655565555555555556555556555555555555555533333333
-- 203:6666666555555554655565545555555455565454555555545555555433555554
-- 204:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 205:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 206:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 207:afff000dafff000dafff000dafff000da000fffda000fffda000fffda000fffd
-- 208:5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa
-- 209:bbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaa
-- 210:bbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaa
-- 211:bbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaa
-- 212:bbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaa
-- 213:bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4
-- 214:6555555365555553656555536555555365555553655555536565556365555553
-- 215:aaaaaaaaa1aaaaa1aa1aaa1aaaa1a1aaaaaa1aaaaaa1a1aaaa1aaa1aa1aaaaa1
-- 216:a3545454a3555554a3555554a3555554a3555554a3554554a3555554a3555554
-- 217:6555555365555553656555536555555365555553655555536565556365555553
-- 218:ddddddddddddddd1dddddd1dddddd1ddddddd1ddd1dd1ddddd1d1dddddd1dddd
-- 219:d3545454d3555554d3555554d3555554d3555554d3554554d3555554d3555554
-- 220:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 221:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 222:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 223:afff000dafff000dafff000dafff000da000fffda000fffda000fffda000fffd
-- 224:5ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb
-- 225:ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb
-- 226:ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb
-- 227:ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb
-- 228:ccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb
-- 229:ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb4
-- 230:6555555365555553656555526555555565555555655555556555655565555555
-- 231:aaaaaaaa33333333222222225555555555555455555555555545555555555555
-- 232:a354555433555554225555545555555454555454555555545555555455555554
-- 233:6555555365555553656555526555555565555555655555556555655565555555
-- 234:dddddddd33333333222222225555555555555455555555555545555555555555
-- 235:d354555433555554225555545555555454555454555555545555555455555554
-- 236:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 237:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 238:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 239:afff000dafff000dafff000dafff000da000fffda000fffda000fffda000fffd
-- 240:5aaaaaaa5ccccccc5bbbbbbb5aaaaaaa5ccccccc5bbbbbbb5555555554444444
-- 241:aaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb5555555544444444
-- 242:aaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb5555555544444444
-- 243:aaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb4444444444444444
-- 244:aaaaaaaaccccccccbbbbbbbbaaaaaaaaccccccccbbbbbbbb4444444444444444
-- 245:aaaaaaa4ccccccc4bbbbbbb4aaaaaaa4ccccccc4bbbbbbb44444444444444444
-- 246:6555555565555555655555556555555565565555655555556555555554444444
-- 247:5555555555555554455545555555555555555554555555555555555544444444
-- 248:5554555455555554555555545555555455455454555555545555555444444444
-- 249:6555555565555555655555556555555565565555655555556555555554444444
-- 250:5555555555555554455545555555555555555554555555555555555544444444
-- 251:5554555455555554555555545555555455455454555555545555555444444444
-- 252:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 253:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 254:ffff0000ffff0000ffff0000ffff00000000ffff0000ffff0000ffff0000ffff
-- 255:afff000dafff000dafff000dafff000da000fffda000fffda000fffda000fffd
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
-- 060:fffffffff888ffffffffffffffffffffffffffffffffff88ffffffffffffffff
-- 061:ffffffffff888fffffffffffffffffffffffffff8ffffffffffffff8ff999fff
-- 062:fffffffffffffffffffffffff9999fffffffffffffffffff88ffffffffffffff
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
-- 076:ffff888ffffffffffffffffffffffffffffffffffffffffffff9999fffffffff
-- 077:ffffffffffffffffffffffffffffffffffffffffffff888fffffffffffffffff
-- 078:fffffffffffffffffff999ffffffffffffffffffffffffffffffffffffffffff
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
-- 092:ffffffffffffffffffff8888ffffffffffffffffffffffffffffffffffffffff
-- 093:ff888fffffffffffffffffffffffffffffffffffff9999ffffffffffffffffff
-- 094:ffffffffffffffffff888fffffffffffffffffffffffffffffffffffffffffff
-- 095:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 096:7777777676666555766557777657777576577558757758887577588865758888
-- 097:5555555576bbbb67755555575888988588889888888898888888988888889888
-- 098:7777777655566665777556655777756585577565888577558885775588885755
-- 099:7777777676666555766557777657777576577558757758887577588865758888
-- 100:5555555576eeee67755555575888988588889888888898888888988888889888
-- 101:7777777655566665777556655777756585577565888577558885775588885755
-- 102:4444444343333332433433324333323243433332433323324333333232222222
-- 103:4444444343333332431111124122122112221222122212221232123212221222
-- 104:4444444343333332433433324333323213433332133323321333333212222222
-- 105:7777777676666665766766657666656576766665766656657666666565555555
-- 106:7777777676666665761111157122122112221222122212221232123212221222
-- 107:7777777676666665766766657666656516766665166656651666666515555555
-- 111:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 112:5775888857588888575888885759999957588888575888885758888857758888
-- 113:8899998889888898988888899888888998888889988888898988889888999988
-- 114:8888577588888575888885758888857599999575888885758888857588885775
-- 115:5775888857588888575888885759999957588888575888885758888857758888
-- 116:8899998889888898988888899888888998888889988888898988889888999988
-- 117:8888577588888575888885758888857599999575888885758888857588885775
-- 118:4444444343333332433433324333323243433332433323324333333232222222
-- 119:122212221222122212221222122212221232123212221222122ba222111aa111
-- 120:1444444313333332133433321333323213433332133323321333333212222222
-- 121:7777777676666665766766657666656576766665766656657666666565555555
-- 122:122212221222122212221222122212221232123212221222122ba222111aa111
-- 123:1777777616666665166766651666656516766665166656651666666515555555
-- 127:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 128:7575888875775888757758887657755876577775766557777666655565555555
-- 129:88898888888988888889888888898888588988857555555776bbbb6755555555
-- 130:8888575688857755888577558557756557777565777556655556666565555555
-- 131:7575888875775888757758887657755876577775766557777666655565555555
-- 132:88898888888988888889888888898888588988857555555776eeee6755555555
-- 133:8888575688857755888577558557756557777565777556655556666565555555
-- 134:4444444343333332433433324333323243433332433323324333333232222222
-- 135:1222222212223222123222321222222212211222412112214311111232222222
-- 136:1444444313333332133433321333323213433332433323324333333232222222
-- 137:7777777676666665766766657666656576766665766656657666666565555555
-- 138:1222222212223222123222321222222212211222712112217611111565555555
-- 139:1777777616666665166766651666656516766665766656657666666565555555
-- 143:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 144:fffffffffffffffaffffffaafffffaacffffaaccfffaacccffaaccccffaacccc
-- 145:faaaaaafaaaaaaaaaccccccacccccccccccccccccccccccccccccccccccccccc
-- 146:ffffffffafffffffaaffffffcaafffffccaaffffcccaafffccccaaffccccaaff
-- 147:fffffffffffffffdffffffddfffffddeffffddeefffddeeeffddeeeeffddeeee
-- 148:fddddddfdddddddddeeeeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 149:ffffffffdfffffffddffffffeddfffffeeddffffeeeddfffeeeeddffeeeeddff
-- 150:aaaaaaaaa0000000a0000000a0000000a0000000a0000000a0000000a0000000
-- 151:aaaaaaaa00000000000000000000000000000000000000000000000000000000
-- 152:aaaaaa00000000d0000000d0000000d0000000d0000000d0000000d0000000d0
-- 159:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 160:ffaaccccfaacccccfaacccccfaacccccaaccccccaaccccccaaccccccaacccccc
-- 161:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 162:ccccaaffcccccaafcccccaafcccccaafccccccaaccccccaaccccccaaccccccaa
-- 163:ffddeeeefddeeeeefddeeeeefddeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeee
-- 164:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 165:eeeeddffeeeeeddfeeeeeddfeeeeeddfeeeeeeddeeeeeeddeeeeeeddeeeeeedd
-- 166:a0000000a0000000a0000000a0000000a0000000a0000000a0000000a0000000
-- 168:000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000d0
-- 169:5555555556666665566666655666666556666665566666545666654455555444
-- 170:4555555445666654456666544566665444555544444444444444444444444444
-- 171:5555555556666665566666655666666556666665456666654456666544455555
-- 172:2222222223333333233333332332222223321111233211112332111123321111
-- 173:2222222233333333333333332222222211111111111111111111111111111111
-- 174:2222222233333332333333322222233211112332111123321111233211112332
-- 175:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 176:aaccccccaaccccccaaccccccaaccccccfaacccccfaacccccfaacccccffaacccc
-- 177:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 178:ccccccaaccccccaaccccccaaccccccaacccccaafcccccaafcccccaafccccaaff
-- 179:ddeeeeeeddeeeeeeddeeeeeeddeeeeeefddeeeeefddeeeeefddeeeeeffddeeee
-- 180:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 181:eeeeeeddeeeeeeddeeeeeeddeeeeeeddeeeeeddfeeeeeddfeeeeeddfeeeeddff
-- 182:a0000000a0000000a0000000a0000000a0000000a0000000a0000000a0000000
-- 184:000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000d0
-- 185:4444444455554444566654495666544956665449566654445555444444444444
-- 186:4994499498899889887888888788888888888888988888894988889444988944
-- 187:4444444444445555944566659445666594456665444566654444555544444444
-- 188:2332111123321111233211112332111123321111233211112332111123321111
-- 189:1111111111111111111111111111111111111111111111111111111111111111
-- 190:1111233211112332111123321111233211112332111123321111233211112332
-- 191:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0a00000d0
-- 192:ffaaccccffaaccccfffaacccffffaaccfffffaacffffffaafffffffaffffffff
-- 193:ccccccccccccccccccccccccccccccccccccccccaccccccaaaaaaaaafaaaaaaf
-- 194:ccccaaffccccaaffcccaafffccaaffffcaafffffaaffffffafffffffffffffff
-- 195:ffddeeeeffddeeeefffddeeeffffddeefffffddeffffffddfffffffdffffffff
-- 196:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeedddddddddfddddddf
-- 197:eeeeddffeeeeddffeeeddfffeeddffffeddfffffddffffffdfffffffffffffff
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
-- 208:ffffffffffffffffaaaaaaaafcfcfcfcbfbfbfbffcfcfcfcbfbfbfbffcfcfcfc
-- 209:ffffffffffffffffaaaaaaaafcfcfcfcbfbfbfbffcfcfcfcbfbfbfbffcfcfcfc
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
-- 224:bfbfbfbffcfcfcfcbfbfbfbffcfcfcfcbfbfbfbfaaaaaaaaffffffffffffffff
-- 225:bfbfbfbffcfcfcfcbfbfbfbffcfcfcfcbfbfbfbfaaaaaaaaffffffffffffffff
-- 226:000000000000000000000000000000000000000000000000dddddddd00000000
-- 227:00000000000000000000000000000000000000000000000000000000a0000000
-- 233:44444444555544445666544a5666544a5666544a5666544a5555444444444444
-- 234:aabbbbaaabbbbbbabbbaabbbbba44abbbba44abbbbbaabbbabbbbbbaaabbbbaa
-- 235:4444444444445555a4456665a4456665a4456665a44566654444555544444444
-- 236:7fffffff7fffffff7ffffcff7fffcfff7ffcffff7fffffff7fffffff7ffffffc
-- 237:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcfff
-- 238:fffffffcfffffffcfffffffcfffffffcfffcfffcffcffffcfffffffcfffffffc
-- 239:a00000d0a00000d0a00000d0a00000d0a00000d0a00000d00dddddd000000000
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
-- 255:1111888811118888111188881111888888881111888811118888111188881111
-- </SPRITES>

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
-- 025:9008e79008f79008e79008f79008e79008f74008e94008f94008e94008f9b008e7b008f7c008e7c008e7c008e7c008f79008e79008f79008e79008f79008e79008f75008e95008f95008e95008f9b008e7b008f7c008e7c008e7c008e7c008f77008e77008f77008e77008f77008e77008f74008e94008f94008e94008f9b008e7b008f7c008e7c008e7c008e7c008f7e008e7e008f7e008e7e008f7e008e7e008f7c008e7c008f7c008e7c008f7b008e7b008f7e008e7e008e7e008e7e008f7
-- 026:9008e94008ebb008e9c008e99008e94008ebb008e9c008e99008e94008ebb008e9c008e9e008e9c008e9b008e9c008e99008e94008ebb008e9c008e99008e94008ebb008e9c008e99008e94008ebb008e9c008e9e008e9c008e9b008e9c008e99008e94008ebb008e9c008e99008e94008ebb008e9c008e99008e94008ebb008e9c008e9e008e9c008e9b008e9c008e99008e94008ebb008e9c008e99008e94008ebb008e9c008e99008e94008ebb008e9c008e9e008e9c008e9b008e9c008e9
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
-- 041:9008d79008d79008c70000009008d79008d79008c7000000c008d7c008d7c008d7c008d7c008c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:9008d59008d59008c50000009008d59008d59008c5000000c008d5c008d5c008d5c008d5c008c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 043:9028c5902cc59008c59008c59008c59008c59008c59008c54008c74008c74008c74008c7b008c5b008c5c008c5c008c55008c55008c55008c55008c55008c55008c55008c55008c57008c57008c57008c57008c58008c58008c58008c58008c59008c59028c59008c59008c59008c59008c59008c59008c54008c74008c74008c74008c7b008c5b008c5c008c5c008c55008c55008c55008c55008c55008c55008c55008c55008c57008c57008c57008c57008c58008c58008c58008c58008c5
-- 044:9428d79428c74008d94008c9c008d7c008c7e008d7e008c7b008d7b008c7c008d7c008c79008d79008c78008d78008c79008d79008c74008d94008c9c008d7c008c7e008d7e008c75008d95008c9b008d7b008c7e008d7e008c78008d78008c79008d79008c74008d94008c9c008d7c008c7e008d7e008c7b008d7b008c7c008d7c008c79008d79008c78008d78008c79008d79008c74008d94008c9c008d7c008c7e008d7e008c75008d95008c9b008d7b008c7e008d7e008c78008d78008c7
-- 045:9028c3902cc39008c39008c39008c39008c39008c39008c34008c54008c54008c54008c5b008c3b008c3c008c3c008c35008c35008c35008c35008c35008c35008c35008c35008c37008c37008c37008c37008c38008c38008c38008c38008c39008c39028c39008c39008c39008c39008c39008c39008c34008c54008c54008c54008c5b008c3b008c3c008c3c008c35008c35008c35008c35008c35008c35008c35008c35008c37008c37008c37008c37008c38008c38008c38008c38008c3
-- 046:9428d59008c54008d74008c7c008d5c008c5e008d5e008c5b008d5b008c5c008d5c008c59008d59008c58008d58008c59008d59008c54008d74008c7c008d5c008c5e008d5e008c55008d75008c7b008d5b008c5e008d5e008c58008d58008c59008d59008c54008d74008c7c008d5c008c5e008d5e008c5b008d5b008c5c008d5c008c59008d59008c58008d58008c59008d59008c54008d74008c7c008d5c008c5e008d5e008c55008d75008c7b008d5b008c5e008d5e008c58008d58008c5
-- 047:9428e79428f74008e94008f9c008e7c008f7e008e7e008f7b008e7b008f7c008e7c008f79008e79008f78008e78008f79008e79008f74008e94008f9c008e7c008f7e008e7e008f75008e95008f9b008e7b008f7e008e7e008f78008e78008f79008e79008f74008e94008f9c008e7c008f7e008e7e008f7b008e7b008f7c008e7c008f79008e79008f78008e78008f79008e79008f74008e94008f9c008e7c008f7e008e7e008f75008e95008f9b008e7b008f7e008e7e008f78008e78008f7
-- 048:9428e59428f54008e74008f7c008e5c008f5e008e5e008f5b008e5b008f5c008e5c008f59008e59008f58008e58008f59008e59008f54008e74008f7c008e5c008f5e008e5e008f55008e75008f7b008e5b008f5e008e5e008f58008e58008f59008e59008f54008e74008f7c008e5c008f5e008e5e008f5b008e5b008f5c008e5c008f59008e59008f58008e58008f59008e59008f54008e74008f7c008e5c008f5e008e5e008f55008e75008f7b008e5b008f5e008e5e008f58008e58008f5
-- 049:9028b59028b59008b59008b59008b59008b59008b59008b54008b74008b74008b74008b7b008b5b008b5c008b5c008b55008b55008b55008b55008b55008b55008b55008b55008b57008b57008b57008b57008b58008b58008b58008b58008b59008b59028b59008b59008b59008b59008b59008b59008b54008b74008b74008b74008b7b008b5b008b5c008b5c008b55008b55008b55008b55008b55008b55008b55008b55008b57008b57008b57008b57008b58008b58008b58008b5870bb5
-- 050:9428b99428b94008bb4008bbc008b9c008b9e008b9e008b9b008b9b008b9c008b9c008b99008b99008b98008b98008b99008b99008b94008bb4008bbc008b9c008b9e008b9e008b95008bb5008bbb008b9b008b9e008b9e008b98008b98008b99008b99008b94008bb4008bbc008b9c008b9e008b9e008b9b008b9b008b9c008b9c008b99008b99008b98008b98008b99008b99008b94008bb4008bbc008b9c008b9e008b9e008b95008bb5008bbb008b9b008b9e008b9e008b98008b98008b9
-- </PATTERNS>

-- <TRACKS>
-- 000:0001800001c0000101000000000000000000000000000000000000000000000000000000000000000000000000000000000010
-- 001:6d58566d5856ad5856ad5856000000000000000000000000000000000000000000000000000000000000000000000000460050
-- 002:0c6c57b97c57b97c570c7020048c571a8c570c8c57329c57b596e986aaea000000000000000000000000000000000000000060
-- 003:c20000c6b000cab000c6bf20c2c000c2c1300000002fc0000000000000000000000000000000000000000000000000000000f0
-- 007:5000006c1000842000ac2c00dc1000ec1f000540002d4000455000000000000000000000000000000000000000000000000080
-- </TRACKS>

-- <SCREEN>
-- 000:ccaabbccaabbccaabccabbc555433333342434343343333541411144111455442223333332243344344333224442223333325511111111111111111111111111111111111411111111113331441411141111444111114113551111111111111111111111bbbcc11111111441111111111111115555666665
-- 001:bcc777bbccabbccaabc77bcc55533377777447773434347777714111414143444442223332247737777333777334442223325511111111111111111111111b11111111114111111111111133311411141414111441114335511111111111111111111111cc11111111144111111111111111111555565576
-- 002:bb77aaa7777aab7777b77abcc55443774443773773344477541177774417777477374427772477333377377277333447727255777711111111111111111bbbcc1111111441111111111111113331144411141114144433511111111111111111111111111111111114411111111111111111111155557666
-- 003:a77777a77bc7a777caabccabcc55337777237773734343777711774171741774777773774773333377723777473333377777577711111111111111111111c1111111114411111111111111111133311411141414111355111111111111111111111111111111111441111111111111111111111115655666
-- 004:aa77ccc77bb7caa777a77ccabc5554443774772473334377654477114171477473737477743477277333377447443447372751177717711111111111111111111111144111111111111111111111333144411114113551111111111111111111111111111111144111111111111111111111111111555566
-- 005:ca77bbc7777bc7777cc77bcaabc5557777233777333334774461774111177773737473477722774777773377733333373727577771177111111111111111111111111411111111111111111111111133314411113351111111111bb111111111111111111114411111111111111111111111111111155555
-- 006:ccaabbb77aabbccaabccaabcaabc55543424443433443444555411111444113343333333332243334442222443332332332551111111111111111111111111111111411111111111111111111111111133314143551111111bcbc1c111111111111111111141111111111111111111111111111111115511
-- 007:bccaaabbccaabbccaabccaabcaabc555342434332334444554561144411141133433323223224333333444333233333332251111111111bb11111111111111111114411111111111111111111111111111333135111111111c11111111111111111111114111111111111111111111111111111111111111
-- 008:bb777aab77caa77ccaabccabbcaabc57742773333444334445554147714177433772233333774334334333244772777732251111111bcbc1c111111111177111114411111177117711177711111111111111335111111111111111111111111b111111411111111111111111111111111111111111111111
-- 009:a77cc7a77777c7777caa777ab7777bc77477733443337777457771177114771334444777733243777337777447744227725511777711177711777711177771177741777711771777117711711111111111115555411111111111111111bbbc1c111141111111111111111111111111111111111111111111
-- 010:a77bb7ca77bbc77ab7c77b77a77ca7bc55277433334777454776571774447711377377744277477327377327333337772251117711717717717711717bb771771771771171111177111777111111111111151555444111111111111bbcc11111114111111111111111111111111111111111111111111111
-- 011:c77bb7cc77abb77aa7b777bbc77bcab7755774334337774557745717711177413773337773773773373773273773773333555577111177711177117b71c771777111771111771177117711711111111111511111555444111111111111111111441111111111111111111111111111111111111111111111
-- 012:cc777bbcc777b77ca7bb777bb77bbca7757777343443777755777411777117773773777733774477722773273773777772511577444117771177117c177771177711771111771777711777111111111151111111115554441111111111111144111111111111111111111111111111111111111111111111
-- 013:bccaaabbbccaabbccaabbccabbcabbcab532383333334345544455441141411113433333333244333444222433323223255111115554441111111111111111441111111111111111111111111111111511111111111155544411111111114411111111111111111111111111111111111111111111111111
-- 014:bbcccaabbbccaabbbcaabbccabbcabbca524288333333334455544314141111413333333333224333333343322333333251111111111555444111111111111411111111111111111111111111111155111111111111111155444111111141111111111111111111111111111111111111111111111111111
-- 015:abbbcca77bbccc77777c77777ab777bbc523427773774777773477741177711443344422377227773333322434442222251111111111111155544411111114111111111111111111111111111111511111111bbc111111111555441114111111111111111111111111111111111111111111111111111111
-- 016:a77bb7c77abbbc77abbccaa77c77bcabb5233773337737755557733747717711113777744772773772323224333334435511111111b11111111155444111411111111111111111111111111111151111111c1111111111111115554411111111111111111111111111111111111111111111111111111111
-- 017:c77ab7cccaaabb7777bbcc77bc7777cab5237777733337777555777347771711113773373334777273333224343343325111111bccc1111111111115554411111111111111111111111111111511111111111111111111111111155511111111111111111111111111111111111111111111111111111143
-- 018:cc777bb77ccaabbcc77bb77aab77ab7ca522377433773845775776373771173341377337377377337422224433232332511111111111111111111111114511111111111111111111111111115111111111111111111111111114511155111111111111111111111111111111111111111111111111143333
-- 019:ccc7aaa77cccaa7777ca77bcaab777bbc5223773237737777586777394777111113777723773277733334343223333225111111111111111111111111141111111111111111111111111115111111111111111111bc111111451111111551111111111111111111111111111111111111111111143323323
-- 020:bbcccaaabbbccaaabbccaabbccabbcaab5334333428333455555553339111111111771122333243333333243344422251111111111111111bbc11111141111111111111111111111111115111111111111111111111111145111111111115551111111111111111111111111111111111111142223333243
-- 021:bbbbcccaaabbcccaabbccaabbccabbcaa533333334233345559556333341118111111111111123333233324343333335111111111111111111111111411111111111111111111111111151111111111111111111111114511111111111111155511111111111111111111111111111111143344422243323
-- 022:aabbbcccaaabbbccaaabbccabbccabbca5333333434233455559553343411181111111111111111112223243333333251111111111111111111111114111111111111111111111111151111111bbc1111111111111145111111bcc1111111111155111111111111111111111111111143434333342233332
-- 023:aaaabbbcccaaabbcccaabbccaabccaabc532377333342775577777327736181117771111771111117777117777733251111111bbc111111111111114111111111111111111111111151111111111111111111111144511111111111111111111114111111111111111111111111143333333243344222433
-- 024:cc7777bb7777a77b7cca777cc7777caa77772773334377759778563777861811771111177711111111177177111222511111111111111111111111411111111111111111111111111144111111111111bbcc1111451111111111111111111111411111111111111111111111142233333243434333422233
-- 025:c777aaa7bb77c77777c77a77b77ab7c7a57733333333377557777533773561117777117717111111177711777711111154111111111111bbcc1114111111111111111111111111111111144111111111111111451111111111111bc111111411111111111111111111111143344222433333332433344225
-- 026:b777cca7ab77c7c7a7b777aab77caab7c577377333333777554577337735611177197177777111117711111117711111111144111111111111111411111111111111111111111111111111114411111111114511111111111111111111141111111111111111111111143434332442233324333333251111
-- 027:bb7777cc7777b7c7a7ab777aa77ccaab77773773333377776777752777755611177711111711111177777177771111111111111144411111111141111111111111111111111111111111111111144111114511111bbc11111111111114111111111111111111111143323232433334423332323251111111
-- 028:aabbbbcccaaabbbcccaabbbccaabbcaab533333333333311766666676735551118111111111111111111111111111111111111111111144111141111111111111111111111111111111111111111114445111111111111111111114111111111111111111111111122332433333324344222511111111111
-- 029:aaaabbbbcccaaabbbcccaabbccaabbcca53333333334331116566665766666611111111111111111111111111111111111111111111111111441111111111111111111111111111111111111111111155544111111111bbc1111411111111111111111111111111443323333243434333511111111111111
-- 030:ccaaaabbbbcccaaabbbccaaabbccaabcc533333333333311117667755765656576671111111111111111111111111111111111111111111111111111111111111111111111111111111111111111151111155441111111111141111111111111111111111111443333321233323325111111111111111111
-- 031:ccccaaaabbbbcccaaabbcccaabbccaabb233333333333355511766666577556676667651111111111111111111111111111111111111111111111111111111111111111111111111111111111115111111111155441111111111111111111111111111111433333343321112225111111111111111111111
-- 032:bbccccaaaabbbccccaabbbccaaabbccab233333333333355566666666676666666566665111111111111111111111111111111111111111111111111111111111111111111111111111111111511111cc111111115544411111111111111111111111143343333333332111114411111111cc11111111111
-- 033:bbbbccccaaaabbbcccaaabbbccaabbcca233233333333345566666666666666565666675111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111415511111111111111111111144333333333323321111111441111111411111111111
-- 034:44bbbbbccccaaabbbcccaaabbcccaabbc233333333333344455555666666666666666656511111111111111111114441111111111111111111111111111111111111111111111111111111511111111111bb1111451111115511111111111111111143333333433333321111111111444111111111111111
-- 035:44444bbbbccccaaabbbcccaaabbccaabb233333333333344455555555555566666666666ddd1111111111111111133333244111111111111111111111111111111111111111111111111511111111111111111511111cc111111511111111111111144333333333333321111111115551111111111111111
-- 036:4444444bbbbccccaaabbbcccaabbbccaa2333333333333444555555555555555555d6666dddddddddd11111111144233243433344411111111111111111111111111111111111111115111111111111b11141111111111111111143411111111111143333333333333321111154144115511111111113442
-- 037:444444444bbbbccccaaabbbcccaabbcca2333333333433444555555666555555555ddddddddddddddddddd6661144343244233233333281111111111111111111111111111111111111144111111111145111111111111111443333323411111111144333333333323321541444141441155111433333234
-- 038:664444444555bbbbcccaaabbbcccaabbc2333233333333444555555666555555dddddddddddddddddddddd6666666663433332444222111111111111111111111111111111111111111111111144115111bcc111111111443342243333323411111143333333333333424441414441444131112324333332
-- 039:66666444445555bbbbcccaaabbbccaaab2333333333333444555555566555555dddddddd00ddddddddddddddd6666666666666323321118181111111111111111111111111111111111111111111545441111111111433233243342243233254551144333333334334324441411411111111111223243333
-- 040:5566666644445555bbbbcccaaabbbccaa2333333334333444555555555555ddddddddddd000000000dddddddddd55555666666666411111911111181115115111111111111111111111111111114111441454411434433422332433333514141111145333453233334424141431111111111111112236665
-- 041:5555566665444445555bbbcccaaabbbcc2333333333333444555445555555ddddd00000000000000000000ddddd55555555555566119181111111111151414114145511111111111111111114111114411141314522433334344225441111441111143333333434344421311111111111111111665655555
-- 042:555555566566644445555bbbcccaaabbb2332333333333444555444555dddddddd00000000000000000000ddddddd555555555566115111911111111511141411114413545111111111115141141411114311114433455233251411114444111131143383333333443321111111111111166655554655556
-- 043:55556656645666664444555bbbbcccaa52333333323333444555444555dddddd0000000000000000000000000dddd555555665566111111115511111114111141141151414111451111514144114414154114143344333333431111141111311119143333833333333321111111166655565555554655555
-- 044:55556656645555666644445555bbbccc52333323333333444555555ddddddddd000000000000000000000000000dddd5555665566111111111111111131411411113141414111114311111133111451441111143334323334433243113111111181149333233323333321116665555655555565554656555
-- 045:5555555664555555566664444555bbbc52333323333333444555555dddddd000000000000000000000000000000dddd55555555666bc111111141111111111341341141141141566111111111114153144141133333334342232221111111111111143333333333224436555555555555555555554655555
-- 046:555555566455565555556666444555bb52333333333333444555ddddddddd00000000000000000000000000000000dddd55555566554451114111111111111111111133411111566666666114111111415314333324222333211111111111111111143333222444334326555655555555555545454656555
-- 047:5555555664555655555555666644445552332333233333444555dddddd00000000000000000000000000000000000dddd555555664554514311115555551111111111111111114555555666aaaaaa14143111152223333111111111111111111111132244333333333226555565555565555555554655555
-- 048:5555555664555555556555555666644452333323332333444555dddddd0000000000000000000000000000000000000ddd555556655454431111155555434119156119111111145555555aaaaaaaaa6666611133433333111111111111111111111143333333333333326555555555555555555554655555
-- 049:5555555664554555555555655555666652233333333333444555dddddd0000000000000000000000000000000000000dddd5555663455431181115555334233324555611111114555655aaacaaaaaaaa56666633333333111111111111111111111143343333333333236555555555555555554554656555
-- 050:5555555664554566555555555565555663222333333333444555dddddd000000000000000000000000000000000000000dd555566544576656111555332433344325561111111455555aaaacccccccaa55555634333333111111111111111111111144333333433333336555555555555555555554655555
-- 051:5555655664555556555655555565555562444222333343444555dddddd000000000000000000000000000000000000000dddd5566553756766575655555223331555561111111454455aacccccccccaaa5565633333333111111111111111111111143333333333333336555565555555555545554656555
-- 052:5555655664555555555655555555555662333442223333444555dddddd000000000000000000000000000000000000000dddd556655555155666155555811665767755111111145445aacccccccccccca5555633333211111111111111111111111143333334333333336555555565555555555554655555
-- 053:5555555664555555555555555655555562343334442223444dddddd00d000000000000000000000000000000000000000dddd5566332451c118195554551115676655611111114555aacccccccccccccc5555632111111111111111111111111111143333333333332332555555655555554555454655555
-- 054:5555555664555555555555555555655562333433334442444dddddd000000000000000000000000000000000000000000dddd556634333321111155555511111656765111111145aaaacccccccccccccca555611111111111111111111111111111143333343333333332555555555555555555554655555
-- 055:5555555664555555535555555555555562233333333334444dddddd000000000000000000000000000000000000000000dddd556611111111111155555514111165656111111845aaacccccccccccccccaa55611111111111111111111111111111113333433333333232555555554555555555554655555
-- 056:5555555644544545533333355555555562333343333333444dddddd00000000000000000000000000000000000000000000dddd6611111111111133333311111155555118111145aaaccccccccccccccccaa5611111111111111111111111111111113333333333333332655555555555455555554655555
-- 057:555555564454454553ddd3333333555562333343343334444dddddd00000000000000000000000000000000000000000000dddd6611111111111133333311111155555555551145aaaccccccccccccccccaa5611111111111111111111111111111113343333333332332655555455545555555554655655
-- 058:555665564455555553dddddddd33555563333333333434444dddddd00000000000000000000000000000000000000000000dddd6611111111111133333311111155555555551145aaaccccccccccccccccaa5611111111111111111111111111111113333333332333332655555555555455455554655555
-- 059:555665564455555533d1ddddddd5555563333333333334444dddddd00000000000000000000000000000000000000000000dddd661111111111113333331111115555555555114aaacccccccccccccccccaa5611111111111111111111111111111113333333332323332655555555555555555544544444
-- 060:555555564455555533ddddddddd5555563223333333334dddddd00000000000000000000000000000000000000000000000dddd665666661111113333331111115555555555114aaaccccccccccccccccccaa611111111111111111111111111111113333333333333332544444444446666666665443333
-- 061:555555564455555533dd1dddddd5555563333334343334dddddd00000000000000000000000000000000000000000000000dddd664555555555555666661111115555555555114aaaccccccccccccccccccaa611111111111111111111111111111114222222244444443655555555555555556554434333
-- 062:555555564455555533ddd1ddddd5555563333333333334dddddd0000000000000000000000000000000000000000000000000dddd4465555552222255555555555555555555114aaaccccccccccccccccccaa611111111111111111111111114444424333333333433432655555555555555555554433333
-- 063:555555564455555533ddd1ddddd5555563333333333334dddddd0000000000000000000000000000000000000000000000000dddd4555555527776722655555555555555555114aaaccccccccccccccccccaa611111111111116666533334343433324333333334334322655565555555555555554434333
-- 064:555555564455555533ddd1ddddd5555563333333333344dddddd0000000000000000000000000000000000000000000000000dddd455555527777677725555555555555555511aacccccccccccccccccccccaa5555555a555655555533433333333324333333333333332655555555555555555554433333
-- 065:55555556445544553ddddd1dd135555563333333333334dddddd0000000000000000000000000000000000000000000000000dddd455555277777bb7b72555555555555555518aacccccccccccccccccccccaa55555565555555555533333333333324333333343332332655555565555555545554433333
-- 066:55566556445555553ddddd1dd135555563333333333334dddddd0000000000000000000000000000000000000000000000000dddd455552aaaaaab77b77255555555555555634aacccccccccccccccccccccaac5555555555556555533333333333324333333333333332655555555555555555554433333
-- 067:55566566445555553ddddd1d1d36556563333333334334dddddd0000000000000000000000000000000000000000000000000dddd455452aabbba677777255555555555555633aacccccccccccccccccccccaa55555555555555555533333333333324333333333323332655555555655554555554433333
-- 068:55555566445555553dddddd1dd35555563333333333334dddddd0000000000000000000000000000000000000000000000000dddd45552aaabbbabb777dd25555545555555638aacccccccccccccccccccccaa55565b55555555554533333333333324333333333333332655555555555555555554443433
-- 069:55555566445555553dddddd1dd35555563323333333334dddddd0000000000000000000000000000000000000000000000000dddd45452aaabbba677777725555555555555633aacccccccccccccccccccccaa55555555555555555533333333332324333333333332332655555555555555555554443333
-- 070:55555566455555453ddddddddd35555523323333333334dddddd0000000000000000000000000000000000000000000000000ddd445552aaaaaab677d77d25555555555555633aacccccccccccccccccccccaa55555555555555555533334333333324433343323333332655555555554555555554443333
-- 071:555555664555555533333333333555552333333334334ddddddd0000000000000000000000000000000000000000000000000ddd445552aaaaabb677d7dd72555555555555539aacccccccccccccccccccccaa55555555555555555533333333333224333333333333332655555555555555555555443333
-- 072:555555664555555533333332222555652333333333333ddddddd0000000000000000000000000000000000000000000000000ddd445552aaaaabb677777772555555555565533aacccccccccccccccccccccaac5555545555555555533333333333324343332333333332655555555555555555555443333
-- 073:555555664555555522222222222555552333333333333ddddddd0000000000000000000000000000000000000000000000000ddd445552aaabbaa677777772555555555555532aacccccccccccccccccccccaa5555a555555555555533333333332324333333333333332655555555555555555555443334
-- 074:555665664555555555555555555555552333233333333ddddddd0000000000000000000000000000000000000000000000000ddd445452aaaaaab677777772555555455555343aacccccccccccccccccccccaa55555555555555545534333333333324333323232333332655555555555555554555443333
-- 075:555655664555555555555555555555552333333323343ddddddd0000000000000000000000000000000000000000000000000ddd445552aaaaaba677777772555555555555333aaccccccccccccccccccccaa655234232342324444533333333333324333333333333332655555455545555555555443333
-- 076:555555664555555545554555555555552333333323333ddddddd000000000000000000000000000000000000000000000000dddd445552aaaaaab6777777255555555555553324aaaccccccccccccccccccaa634323343423243423343434322222224333333333333332656555555555545545555443333
-- 077:555555664554555545555555555555552333333333333ddddddd0000000000000000000000000000000000000000000000dddd66445552aaaaaaa6777777244444444433234234aaaccccccccccccccccccaa623334324343343433343342343333442323334322222222655555555555555555555443333
-- 078:555555664555555555555554555555552333333333333ddddddd0000000000000000000000000000000000000000000000dddd6634444422323333442232333344334342332334aaacccccccccccccccccca5633243342323333244232433333432433442232333344423324334233324444444444432333
-- 079:555555664555555555555554555555552332323332333ddddddd00d0000000000000000000000000000000000000000000dddd6632442324333344233434332444232333334424aaacccccccccccccccccaa5643333244233433332442232433332442334333332442334333233434423332433442324343
-- 080:5555556645555555555555555555555523333332333334444dddddd0000000000000000000000000000000000000000000dddd6633324333324423343433344223243333244224aaaaccccccccccccccccaa5632333332442332433332444232433333244233243333344423324343334442224332343334
-- 081:5555556645555555555555555555555623333333333434444dddddd0000000000000000000000000000000000000000000dddd66433333442233243333244423324333324442245aaaccccccccccccccccaa5623324333334442234333224333422243333332442233243333323442324333323343244223
-- 082:655555664555555555555555555555562333333333333444ddddddd0000000000000000000000000000000000000000000dddd66324442333433333323442234333332433442245aaacccccccccccccccca55644223433333243333244223243333344344223243333332442233332443433342223243333
-- 083:655555664555545555555555545555562332323333332444ddddddd00000000000000000000000000000000000000000dddd5566333244233332434343334222332433333243345aaacccccccccccccccaa55634433442223324333332433343422233433323243334422243333332434422332433333343
-- 084:555555664555545555455455545555562333333332224444ddddddd00000000000000000000000000000000000000000dddd5566333332434422324333333243344222433232345aaaccccccccccccccaa555622333232232433344222433232324334332444223433233243434333422333332433333442
-- 085:555555644555555555555455555556562333332223333444ddddddd00000000000000000000000000000000000000000dddd556622333332433333432333233324343433234224555aacccccccccccccc5655633333244334422324333333324444422332443333334333444232333324333333243444222
-- 086:555555644555555555555555555555562333222433344444ddddddd00000000000000000000000000000000000000000dddd5566433344422443333333243344422243323323245555aacccccccccccca5655622444422332433333333243442233324434434333344223333244343333243344423233233
-- 087:5555556445555555555555555555555622224333332334445555ddddd000000000000000000000000000000000000000dddd5566243333333324344422332433333333243444245555aaacccccccccaaa5555633333224333333224344222332443343443323442233333324434343333442223332443333
-- 088:5555556445555555554555555555554524433444422234445555ddddd000000000000000000000000000000000000000dddd55663244444223332433333333244344222332433454455aacccccccccaa55555633243333334344222333243333333332444422233332443443443343432233333244343343
-- 089:555555644555554455455555555444443333332332443444555dddddd00000000000000000000000000000000000000ddd55556633224333333332443311111224433333333224544555aaacccaaaaaa55444534444222433333332433433332443444222332443333333332244422233333244343343332
-- 090:555555644554554555555555544444333333444233233444555dddddd0000000000000000000000000000000000000dddd555566233224333311122122222211112443333344445555555aaaaaaaaa4444442222433323323244333443324444422232443333333332243344422233244333333333324444
-- 091:555555644544555555555544443222333333324434433444555dddddd0000000000000000000000000000000000000dd55555566311112222222222aaa222322211333422233345555555aaaaaaaaa4322333333332243333433333444222233224333332322433333344422243333233233224433334442
-- 092:555555644555555555544444433333333332443334444444555dddddd00000000000000000000000000000000000dddd5555556622222211112222322212211122223322433334555544444aaa22233322443343343333224444222233244333333332243333333434422233333332244343333334433332
-- 093:565555644555555554444433333344442233233333333444555dddddd0dd00000000000000000000000000000000ddd5665555662222233222222111122224433323322322433444444442234333323322322443333444422224433322322322433333333333442222333324433333333332244444422233
-- 094:665555644555554444442222233333224433333333332444555555dddddd000000000000000000000000000000dddd55665555663111111122323333333332243344344333224444222333332244334334433333444222333333322443443343332244444222223224333233223224333333344422234333
-- 095:655555644554444444333233323322443333333344432444555555dddddd0dd000000000000000000000000000dddd55555555662223333332244333333333322433344442222244333323323332244333344442222244333333333332244333344442223433332333332243343344333244442222333332
-- 096:555556644444444334433443332244444422223332244444555555555dddddd0000000000000000000000000dddd5555555555663333333233224433333334444333223333333332243344334433332444422233333332244334433443333334422223333332243333333333324433344444222244333223
-- 097:555556544444433333444442223433332233223322433444555555555dddddd0dd0000000000000000000ddddddd5555555555663344334433332444444222233322443333333333322443333344442222443333223322332244333333444422222443332233223224433333333343344222233333332243
-- 098:555445544444222223333322443333333333332244334444555555555555dddddd0000000000000000000ddddd555555555554554333334444422223433332333333224433433344333224444222233333322443334333433332224444222233333322243334333333332443344444222222443333233323
-- 099:544445343333223322332244333333333334433432223444555444555555ddddddddddd00000000000dddddddd555554444444554444222223333322443333333333332244333334444422223433332233223322443333333334444223333333223322332244333333333344334322223333333224433443
-- 100:444443333333333333224433344444222222244333322444555444555555555dddddddd0000dddddddddddddd4444444444442223333333223332332244334433344333323444422222333332244333333333333322443344442222233224443333333333333224433344444222222443333223332233224
-- 101:444334333443333333444222223333333222443334333444555455555555555dddddddddddddddddddddd44444444442222233322443333333333333222443333334444422223433333233333322244334333433333433442222333333333322443344433443333333444222223333333224433333333333
-- 102:333333344444222234333332233222332244333333333444555555555555555555ddddddddddddddddddd44443222233333333322244334443344333332244444422222233322244333333333333322443333334444422222443333322333223322244333333334444422233333332233323322244333333
-- 103:444222223333224433333333333333222443333344444444555555555555555555dddd4dddddddddddd2222244333332233222332244433333333334444333322233333333333224443344333443333224444444222223333322443333333333333332244334444422222333224433333333333333224443
-- 104:33333333322244333443344433333224444444222223344455555555555555554444444dddddd2222223332244333333333333333224433333444444222222444333332233222332244433333333333443334322223333333333322443334433344333333334442222233333333222443334433344333332
-- 105:33222332224433333333333344433333222333333333344455555555544444444444444d222223333333332244433444334433333222444444422222333332224433333333333333322443333344444422222244433333223332233322444333333333444442223343333322333223322244333333333333
-- 106:333332224433333344444422222244433333223332233444555444444444444444223333333332333323332244433333334333334433443222233333333333222443334433344333332224444444222222333322444333333333333333222444333444444222223224443333333333233332224433333334
-- 107:333222443444442222223333222443333333333333333444444444444444222222224433333323333233332244433333333444444222233433333222332223322244433333333333334433343222223333333333222443334443344433333222444444222222333333222443333333333333333222443344
-- 108:333344422222233333333322244433344333343333332444444444222222333332244433333333333333332224433344444422222232224443333333333233333224443333333344444422222343333322233322333224443333333333333344333333222333333333333322444333443334443333323344
-- 109:223323333333233333333222443334333344333333433444222222333333333322244433344333444333332224444442222223333333222443333333333333333322444333444444222222332244433333333333233332224433333333344444422222343333332223322233322244333333333333344443
-- 110:443333332223332233322244433333333333444444222332333333223333233322244333333333333333343334432222233333333333222444333444334443333332224444442222222333333222444333333333333333322244433344444422222233222443333333333333333322244433333334444442
-- 111:333333333333333333224443333334444444222222224433333322233322233322444333333333334444442223333333332233333233322244433333333433333344333443222223333333333332224443344433344433333322444444442222223333333224443333333333333333332244433344444422
-- 112:333433333433333322244434444442222222333322244433333333333333333222444333333444444222222224443333332233332223332224443333333333444444422233333333332233333233322244333433333433333334333443222222333333333332224443334443334443333332224444444222
-- 113:443334443333332234444442222222333333333222444333334333333333333222444344444422222223332224443333333333333333332224443333334444444222222224443333332223332223332224443333333333334444443223332333333323333323332224443333333334333333343334432222
-- 114:333333333344433343322222333333333333332224443334443334443333332224444444222222333333333222444333334333333333333222444344444442222222333222244433333333333333333322244433333334444444222222244443333332223332223332224443333333333334444444222333
-- 115:333444444422223334333333222333332333322244433333333343333333443334432222223333333333333222444333444333444333333322244444442222222333333332224443333333333333333333222444333444444422222233322244433333333333333333332224443333333344444422222222
-- 116:444422222222244433333332223332223333222444333333333333344444432233332333333323333332333222444333433333343333333433344432222223333333333333222444333444433344433333322244444444422222223333333222444333333333333333333332224443334444444222222233
-- 117:222223332224444333333333333333333332224443333333334444444222222244433333332223332222333222444333333333333334444443223332233333333333333333322244433334433334443333333333444442222222333333333332224444333444333344433333322224444444442222222333
-- 118:333333322244433333333333333333333322244433334444444422222223222244433333333333332333333222444433333333344444442222222344333333322233322223332224444333333333333333344443333332222333333333333333322224443334443333444333333323344444222222223333
-- 119:333332224444333344433333443333332222444444444442222222333333222444433333333333333333333222444433333444444442222222222444433333332333332223333222244433333333333344444442222233333333332223333322333322244433333333333333333344433343332222333333
-- 120:333222244433334443333444333333322234444444222222223333333332222444333333333333333333333222244433444444422222222333322244443333333333333333333322224443333333344444444222222222444333333322233332223333222444433333333333334444444422233333333333
-- 121:332224444333333333334333333334333344432222222333333333333332224444333344433334443333333222244444444422222223333333322224443333333333333333333333222444433344444444222222223322244443333333333333333333332222444333333333344444442222222244443333
-- 122:222244443333333333333334444443332333322233333333333333333322224444333444333344443333333233344444222222223333333333332224444333334433333343333333322244444444444422222222333332222444433333333333333333333322224444333334444444422222222222244433
-- 123:224444333333333333444444444222223334333333322223333222333322224443333333333333333333444333343332222233333333333333332222444433344443333444333333332224444444422222222333333333322224443333333433333333333333322244443444444444222222223333222244
-- 124:244443333333344444444222222222244443333333222233332222333222244443333333333333334444444332233332233333333233333333333222244443334433333344333333334333344442222222233333333333333222244433334444333344433333333222244444444422222222333333333222
-- 125:444333334444444422222222232222444433333333333333322333333222244443333333333344444444422222233443333333322233332222333322244443333333333333333333444433333333222233333333333333333332224444333344443333444333333332333444444222222223333333333333
-- 126:443444444442222222223333322224444333333333333333333333332222444433333333444444444222222222244443333333322223333222333322224444333333333333333444444443222333323333333332233333323333222244443333333333333333333334433334433222222233333333333333
-- 127:444444222222222333333333222244443333333333333333333333332222444433334444444442222222223322224443333333323333333233333332222444433333333333444444444222222233443333333322223333222233332222444433333333333333333444444333233332222333333333333333
-- 128:422222222233333333333332222444433333344333333343333333332222444444444444422222222233333322224444333333333333333333333333222244443333333344444444422222222222444433333333222333332222333322224444333333333333334444444442222233343333333322223333
-- 129:222223333333333333333322224444333334444333344443333333322224444444444422222222233333333322224444333333333333333333333333222244443333344444444422222222233222244443333333333333333233333332222444433333333333444444444222222222444433333333222233
-- 130:377337377773377333333772247774337774443333444433333333323334444444222222222333333333333322224444333333343333333343333333322224444344444444422222222233333322224444333333333333333333333333322224444333333334444444442222222222224444433333333223
-- 131:377337277337377233337772477477377477333334433333333334333344443222222223333333333333333322224444333344444333344443333333322222444444444442222222223333333332222444433333333333333333333333333222244443333444444444422222222233222224444333333333
-- 132:377777377337222333322772477737377737333333333333344444333333332222223333333333333333333322224444333334444333344444333333332223444444442222222222333333333333222244444333333343333333343333333322222444434444444442222222222333333222244443333333
-- 133:377227377772277333222774477337377337333333333444444443222333332233333333332333333332333322224444433334433333334443333333334333344444222222222333333333333333322222444433334444433334444333333333222244444444444422222222233333333332222444443333
-- 134:277337377223377332227777447773337773333334444444442222222333433333333322222333332222333322224444433333333333333333333334444333334333222222233333333333333333332222244443333344443333444443333333332223444444442222222222333333333333322222444433
-- 135:333333333333333322222444433333333333344444444442222222222444433333333322222333322222333322222444433333333333333333333444444433323333322233333333333333333333333322224444433334443333334443333333333333334444422222222223333333333333333222224444
-- </SCREEN>

-- <PALETTE>
-- 000:0000001c181c3838385d5d5d7d7d7dbababad6d6d6fffffff21018ff55553499ba65eef6b2f6fad67918ffbe3cff00ff
-- </PALETTE>

-- <PALETTE1>
-- 000:0000001c181c3838385d5d5d7d7d7dbababad6d6d6fffffff21018ff55553499ba65eef6b2f6fad67918ffbe3cff00ff
-- </PALETTE1>

