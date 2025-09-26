#import "Macros.h"
#include "Unity3D/Vector2.h"
#include "Unity3D/Vector3.h"
#include "Unity3D/Quanternion.h"
#include "Unity3D/Normalize.h"
#include "Unity3D/String.h"
#include "Menu/Obfuscate.h"


struct Player {
    void *ptr;
    void *transform;
    Vector3 position;
};

static Player MinePlayer;
static Player EnemyPlayer;

Vector3 (*RigidbodyCharacterController$$get_Position)(void *);
void (*RigidbodyCharacterController$$set_UseGravity)(void *, bool);
void *(*Ped$$get_controller)(void *);
void (*Ped$$SetPosition)(void *, Vector3);
void *(*Ped$$get_Local)();
void *(*Ped$$get_CurrentVehicle)(void *);
void (*WeaponService$$ScrGivePlayerWeapon)(void *, int, int);
void (*Ped$$SetSkin)(void *, int);
void (*PlayerPool$$OnScrSetPlayerHealth)(float);
void (*Ped$$SetRotation)(void *, float);
void (*HudController$$SetGreenZone)(bool);
void (*Transform$$set_localScale)(void *, Vector3);

inline void Teleport(void *ptr) {
    int point = int([[Switch getValueFromSwitch:@"To location"] floatValue]);

    switch (point) {
        case 0:
            Ped$$SetPosition(ptr, Vector3(-2412, 30, 131));
            break;
        case 1:
            Ped$$SetPosition(ptr, Vector3(1973, 20, 1929));
            break;
        case 2:
            Ped$$SetPosition(ptr, Vector3(-350, 20, 570));
            break;
        case 3:
            Ped$$SetPosition(ptr, Vector3(263, 20, 2842));
            break;
        case 4:
            Ped$$SetPosition(ptr, Vector3(2456, 30, -2543));
            break;
    }
}

inline void TeleportTo(void *ptr) {
    float Xpos = [[Switch getValueFromSwitch:@"X"] floatValue];
    float Ypos = [[Switch getValueFromSwitch:@"Y"] floatValue];
    float Zpos = [[Switch getValueFromSwitch:@"Z"] floatValue];

    Ped$$SetPosition(MinePlayer.ptr, Vector3(Xpos,Ypos,Zpos));
}


void (*ChatManager$$AddMessage)(monoString *);
void _ChatManager$$AddMessage(monoString *text) {
    if ([Switch isSwitchOn:@"Spammer"]) {
        for (int i = 0; i < 11; i++) {
            ChatManager$$AddMessage(text);
        }
    }
    ChatManager$$AddMessage(text);
}

void *WeaponController;
void (*WeaponController$$Awake)(void *);
void _WeaponController$$Awake(void *ptr) {
    if (ptr) {
        WeaponController = ptr;
    }
    WeaponController$$Awake(ptr);
}

bool (*RigidbodyCharacterController$$IsUnderVehicle)(void *, bool);
bool _RigidbodyCharacterController$$IsUnderVehicle(void *ptr, bool value) {
	if (ptr && [Switch isSwitchOn:@"Ignore vehicle hit"]) {
		return false;
	} 
	return RigidbodyCharacterController$$IsUnderVehicle(ptr, value);
}
  

void (*Ped$$Update)(void *);
void _Ped$$Update(void *ptr) {
    if (ptr) {

        if (Ped$$get_Local()) {
            MinePlayer.ptr = Ped$$get_Local();
            MinePlayer.transform = * (void **) ((uint64_t) MinePlayer.ptr + 0x18);

            if (ptr != Ped$$get_Local()) {
                EnemyPlayer.ptr = ptr;
                EnemyPlayer.transform = * (void **) ((uint64_t) EnemyPlayer.ptr + 0x18);
            }
        }

        if (MinePlayer.ptr) {
            void *controller = Ped$$get_controller(MinePlayer.ptr);

            if (EnemyPlayer.transform && [Switch isSwitchOn:@"Big enemies"]) {
                Transform$$set_localScale(EnemyPlayer.transform, Vector3(5.f, 15.f, 5.f));
            } else {
				Transform$$set_localScale(EnemyPlayer.transform, Vector3(1.2f, 1.2f, 1.2f));
			}
			
            if (controller) {
                MinePlayer.position = RigidbodyCharacterController$$get_Position(controller);

                if ([Switch isSwitchOn:@"Teleport location"]) {
                    Teleport(MinePlayer.ptr);	
                }
                if ([Switch isSwitchOn:@"Tele-Kill"]) {
                    if (EnemyPlayer.ptr) {
                        Ped$$SetPosition(EnemyPlayer.ptr, MinePlayer.position);
                    }
                }

                if ([Switch isSwitchOn:@"Set speed"]) {
                    float speed = [[Switch getValueFromSwitch:@"Speed"] floatValue];
                    * (float *) ((uint64_t) controller + 0x20) = speed;
                } else {
					* (float *) ((uint64_t) controller + 0x20) = 80.f;
				}

                if ([Switch isSwitchOn:@"Ignore gravity"]) {
                    RigidbodyCharacterController$$set_UseGravity(controller, false);
                } else {
                    RigidbodyCharacterController$$set_UseGravity(controller, true);
                }
            }
            
            if ([Switch isSwitchOn:@"Instant cure"]) {
                PlayerPool$$OnScrSetPlayerHealth(100);
            }

            float skin = [[Switch getValueFromSwitch:@"Skin"]floatValue];
            if ([Switch isSwitchOn:@"Set skin"]) {
                Ped$$SetSkin(MinePlayer.ptr, skin);
            }

            if (WeaponController) {
				int weapon = int([[Switch getValueFromSwitch:@"Weapon"] floatValue]);
				int ammo = int([[Switch getValueFromSwitch:@"Set ammo"] floatValue]);
				
                if (weapon && ammo && [Switch isSwitchOn:@"Set Weapon"]) {
                    WeaponService$$ScrGivePlayerWeapon(WeaponController, weapon, ammo);
                }
            }

            if ([Switch isSwitchOn:@"Infinity stamina"]) {
                * (float *) ((uint64_t) MinePlayer.ptr + 0xAC) = 100;
            }

            if ([Switch isSwitchOn:@"Ignore green-zone"]) {
                HudController$$SetGreenZone(false);
            }

            if ([Switch isSwitchOn:@"Enable"]) {
                static float spin;
                spin += 1000.0f;
                Ped$$SetRotation(MinePlayer.ptr, spin);
            }
        }
        if ([Switch isSwitchOn:@"Teleport XYZ"]) {
                TeleportTo(MinePlayer.ptr);
                TeleportTo(MinePlayer.ptr);
        }
    }
    Ped$$Update(ptr);
}

void (*BaseScriptState$$FallLogics)(void *);
void _BaseScriptState$$FallLogics(void *ptr) {
    if (![Switch isSwitchOn:@"Disable FallLogics"]) {
        BaseScriptState$$FallLogics(ptr);
    }
}

void (*SetColor)(void *, int);
void _SetColor(void *ptr, int Color) {
    if (ptr && Color) {
        Color = 10;
    }
    SetColor(ptr, Color);
}


void setup () {

    //ВКЛАДКА Player/Main
    [Switch addSwitch1:ObfuscateString("Infinity stamina")];
	[Switch addSwitch1:ObfuscateString("Ignore vehicle hit")];
    [Switch addSwitch1:ObfuscateString("Set speed")];
    [Switch addSliderSwitch1:ObfuscateString("Speed") minimumValue:0 maximumValue:500];
    [Switch addSwitch1:ObfuscateString("Set skin")];
    [Switch addSliderSwitch1:ObfuscateString("Skin") minimumValue:0 maximumValue:100];
    [Switch addSwitch1:ObfuscateString("Ignore gravity")];
    [Switch addSwitch1:ObfuscateString("Ignore green-zone")];
    [Switch addSwitch1:ObfuscateString("Instant cure")];
    [Switch addSwitch1:ObfuscateString("Big enemies")];
    [Switch addSwitch1:ObfuscateString("Device Spoofer")];
    [Switch addSwitch1:ObfuscateString("Disable FallLogics")];

    //ВКЛАДКА Player/Teleport
    [Switch addSwitch2:ObfuscateString("Teleport location")];
    [Switch addSliderSwitch2:ObfuscateString("To location") minimumValue:0 maximumValue:4];
    [Switch addSwitch2:ObfuscateString("Tele-Kill")];
    [Switch addSwitch2:ObfuscateString("Teleport XYZ")];
    [Switch addSliderSwitch2:ObfuscateString("X") minimumValue:-4000 maximumValue:4000];
    [Switch addSliderSwitch2:ObfuscateString("Y") minimumValue:0 maximumValue:200];
    [Switch addSliderSwitch2:ObfuscateString("Z") minimumValue:-4000 maximumValue:4000];


    //ВКЛАДКА Items/Weapon
    [Switch addSwitch3:ObfuscateString("Set Weapon")];
    [Switch addSliderSwitch3:ObfuscateString("Weapon") minimumValue:0 maximumValue:54];

    //ВКЛАДКА Items/Ammo
    [Switch addSliderSwitch4:ObfuscateString("Set ammo") minimumValue:0 maximumValue:9999];

    //ВКЛАДКА Misc/Spin-bot
    [Switch addSwitch5:ObfuscateString("Enable")];

    //ВКЛАДКА Misc/Chat
    [Switch addSwitch6:ObfuscateString("Spammer")];


    INIT_F(RigidbodyCharacterController$$get_Position, ObfuscateOffset("0x1AF8E58"));
    INIT_F(RigidbodyCharacterController$$set_UseGravity, ObfuscateOffset("0x1AF8DD4"));
    INIT_F(Ped$$get_controller, ObfuscateOffset("0x1AEF260"));
    INIT_F(HudController$$SetGreenZone, ObfuscateOffset("0x190145C"));
    INIT_F(Ped$$SetPosition, ObfuscateOffset("0x1AF25AC"));
    INIT_F(Ped$$get_Local, ObfuscateOffset("0x1AEF788"));
    INIT_F(Ped$$SetSkin, ObfuscateOffset("0x1AF2814"));
    INIT_F(Ped$$SetRotation, ObfuscateOffset("0x1AF2380"));
    INIT_F(WeaponService$$ScrGivePlayerWeapon, ObfuscateOffset("0x19DE0B8"));
    INIT_F(PlayerPool$$OnScrSetPlayerHealth, ObfuscateOffset("0x1A98984"));
    INIT_F(Transform$$set_localScale, ObfuscateOffset("0x3EBCC7C"));
    HOOK(ObfuscateOffset("0x19DCB84"), _WeaponController$$Awake, WeaponController$$Awake);
    HOOK(ObfuscateOffset("0x1AF2434"), _Ped$$Update, Ped$$Update);
    HOOK(ObfuscateOffset("0x1AD94FC"), _ChatManager$$AddMessage, ChatManager$$AddMessage);
  HOOK(ObfuscateOffset("0x1AFAEDC"), _RigidbodyCharacterController$$IsUnderVehicle, RigidbodyCharacterController$$IsUnderVehicle);
    HOOK(ObfuscateOffset("0x1B103F0"), _BaseScriptState$$FallLogics, BaseScriptState$$FallLogics);
}

void setupMenu() {
    menu = [[View alloc]initWithTitle];
    setup();
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *ptr, CFDictionaryRef info) { 
    timer(10) {
        
        setupMenu();
    });
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
