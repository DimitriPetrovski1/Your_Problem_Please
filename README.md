# 🖥️ Your Problem, Please

> A cozy cyber-safety game where you sit at your desk and help friends navigate the dangers of the digital world.

<img width="776" height="184" alt="Your Problem, Please" src="https://github.com/user-attachments/assets/ca79df50-65e0-41e6-b357-677a5cba2c8d" />


---

## 🕹️ Play Now

👉 **[Play in Browser / Download](#)** ← *(replace with your itch.io, web build, or .exe link)*

---

## 📸 Screenshots

| Main Desk | Case Review | Ad Minigame |
|:---------:|:-----------:|:-----------:|
| <img width="1273" height="712" alt="Desk View" src="https://github.com/user-attachments/assets/f411688d-465e-4a03-8b6a-50c8e16f5a3b" /> | ![Case](https://placehold.co/280x180?text=Case+Review) | ![Minigame](https://placehold.co/280x180?text=Ad+Minigame) |

| Shop | Rewards |
|:----:|:-------:|
| ![Shop](https://placehold.co/280x180?text=Shop) | ![Rewards](https://placehold.co/280x180?text=Rewards) |


---

## 🎮 How to Play

### The Basics
Each day you help **5 friends** who come to you with their cyber problems. A friend presents you with a situation — an email, a message, or something that happened in real life — and it's your job to figure out whether it's dangerous or safe.

You do this by **checking off sentences** that match what's suspicious (or trustworthy) about the situation. For example:

- An email from `support@totally-not-a-scam.com` → ✅ **Suspicious sender**
- A message asking you to urgently click a link → ✅ **Creates false urgency**
- A legitimate newsletter you signed up for → ✅ **Known sender**, ✅ **No suspicious links**

The more correct checkboxes you tick, the more **💰 money** you earn.

### Problem Categories

| Category | Description |
|----------|-------------|
| 📧 **Email** | Analyse emails for phishing signs — dodgy senders, fake links, urgent language |
| 💬 **Message** | Review texts or DMs for scams, impersonation, and social engineering |
| 🌍 **Real Life** | Evaluate real-world scenarios involving cybersecurity threats |

### 🕹️ Ad Minigame
Feeling like a break? Jump into the **Ad Minigame** — ads scroll up your screen and you have to close them before they disappear off the top. The speed increases over time, so stay sharp! Miss too many and it's game over. Earnings are paid out at the end of each run.

### 🛍️ The Shop
Spend your earnings in the **Shop** to buy trinkets and accessories that decorate your office desk. Make your workspace your own! Items range from desk plants to trophies and other collectibles.

Some items **cannot be bought** — they are locked behind achievements and can only be earned through gameplay milestones.

### 🏆 Rewards & Achievements
Keep playing to unlock special rewards. These are earned through dedication and consistency, for example:

- 🥈 Help **10 kids** with email problems → **Silver Email Medal**
- More rewards are waiting to be discovered...

---

## 📖 Documentation

### Project Structure
Built with **Godot 4**, organized as follows:

```
res://
├── assets/
│   ├── ads/                   # Banner textures for the ad minigame
│   ├── Characters/            # Sprites of friends that come for help
│   ├── Fonts/                 # Game fonts (ByteBounce.ttf, etc.)
│   └── UI/                    # UI textures and frames
├── scenes/
│   ├── mainGameplayScene/     # Main gameplay scene
│   └── shop/
│       └── accessories/       # AccessoryData .tres resource files
│   └── miniGame/              # Ad minigame scene and scripts
└── scripts/
    └── ShopGameData.gd        # Global autoload for money, owned/equipped items
    └── mainGameplayScene.gd   # Global autoload for money, owned/equipped items
```

### Key Systems

**`ShopGameData` (Autoload)**
Global singleton that tracks the player's money, owned items, equipped items, and persistent progress. Exposes methods like `add_money()`, `buy_item()`, `equip_item()`, and `unequip_item()`.

**`AccessoryData` (Resource)**
A custom `Resource` class representing a shop item. Key fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `name` | `String` | Display name |
| `price` | `int` | Cost in game currency |
| `texture` | `Texture2D` | Item image |
| `purchasable` | `bool` | If false, earned via achievement only |
| `unlock_requirement` | `String` | Description of how to earn it |

**Ad Minigame**
Ads spawn from the bottom of the screen and scroll upward at increasing speed. Each ad closed scores a point. Missing too many costs lives — lose all three and the round ends. Earnings are calculated as `score × $5` and paid directly into `ShopGameData`.

**Shop**
Dynamically populated at runtime by scanning `res://scenes/shop/accessories/` for `.tres` files. Supports buying, equipping, and unequipping. Non-purchasable locked items show a popup explaining how to earn them.

**Scroll Containers (Mobile)**
All scroll containers support click-and-drag and touch swipe scrolling, making the game fully compatible with mobile devices.

### Adding New Accessories
1. Create a new `AccessoryData` resource (`.tres`) in `res://scenes/shop/accessories/`
2. Fill in the fields in the Godot inspector
3. Set `purchasable = false` and fill `unlock_requirement` if it's an achievement reward
4. The shop auto-discovers it on next run — no code changes needed

### Adding New Ads
Drop any `.png`, `.jpg`, or `.webp` image into `res://assets/ads/` and it will be automatically loaded into the minigame rotation on next launch.

---

## 🛠️ Built With

- [Godot 4](https://godotengine.org/) — Game engine
- GDScript — Scripting language

---

## 📄 License

*(Add your license here — e.g. MIT, GPL, or All Rights Reserved)*
