# CLAUDE.md — Jogo Sem Nome (roguelike steampunk cooperativo)

Leia este arquivo e `docs/GDD.md` antes de qualquer tarefa. O GDD é a fonte da verdade sobre o design; itens marcados **[A DEFINIR]** não estão decididos e **não devem ser inventados**: pergunte.

## O projeto em resumo
Roguelike cooperativo top-down em pixel art, tema steampunk apocalíptico. De 1 a 4 jogadores defendem um acampamento: de **dia** (5 min) coletam recursos e craftam; à **noite** sobrevivem a hordas de mutantes e protegem o **Cristal de Energia**. Derrota = todos caídos ou Cristal destruído. Meta-progressão desbloqueia opções entre runs. Projeto de **hobby**, sem prazo, feito fase a fase, cada fase jogável.

**Combate:** mira com o mouse (analógico direito no controle), corpo a corpo e à distância, conforme o **personagem inicial** e as **armas craftadas** na run.

## Stack e convenções
- **Godot 4.x** (versão Standard, não .NET), linguagem **GDScript**. Use tipagem estática (`var x: int`, `-> void`).
- **Nomes de arquivos, variáveis e funções em inglês** (`snake_case`; classes e nós em `PascalCase`). **Comentários em português.**
- Pastas: `scenes/`, `scripts/`, `assets/sprites/`, `assets/sounds/`, `docs/`. Itens, torres, inimigos, materiais e upgrades ficam em `resources/` como **Resources do Godot** (dados, não código fixo).
- **Pixel art:** viewport 640x360, stretch mode `viewport`, scale mode `integer`, textura filtro `Nearest`, snap 2D ligado. Não altere essas configurações sem avisar.
- Commits pequenos e em português, descrevendo o que mudou.

## Regras de arquitetura (importantes)
1. **Multiplayer online desde a Fase 1.** Todo sistema nasce preparado para rede, mesmo testado em solo. Modelo **host-autoritativo** (High-Level Multiplayer do Godot): o host decide o estado, os clientes enviam comandos.
2. **Co-op local** (até 2 jogadores, tela dividida dinâmica) reaproveita o mesmo código dos jogadores online. Use **ações do Input Map** (`move_left`, `aim`, `attack`...) e separe "quem controla" do dispositivo de entrada: nunca leia teclas ou botões direto.
3. **Mapa e materiais procedurais por seed compartilhada.** Use `RandomNumberGenerator` com seed; nunca aleatoriedade global na geração.
4. **Conteúdo orientado a dados:** criar uma torre, item ou caminho de upgrade deve ser preencher um Resource, sem reescrever lógica.
5. Evite muitos inimigos simultâneos e IA complexa (custo de sincronização em rede).
6. **Armas são Resources** com tipo (corpo a corpo ou à distância) e 3 caminhos de upgrade. A direção da mira é enviada ao host, que valida os acertos.

## Como trabalhar comigo
- Sou **iniciante em Godot** e com pouca prática de programação. Não assuma experiência prática.
- Entregue **código completo** e **explique parte por parte**, dizendo o que faz e por quê. Termine com sugestões de próximos passos.
- **Seja crítico e honesto:** aponte erros, riscos e pontos fracos nas minhas ideias e no código, mesmo sem eu pedir. Se eu pedir algo que seja má prática ou um caminho mais difícil que o necessário, avise **antes** de fazer.
- **Pergunte antes de alterar algo que já funciona.**
- Se faltar informação, **pergunte antes de começar**. Nunca invente dados ou detalhes. Se não tiver certeza, diga.
- Faça uma fase por vez, na ordem do roadmap. Não adiante sistemas de fases futuras.

## Roadmap
0. Básico do Godot + Git/GitHub
1. Personagem top-down que anda, mira com o mouse e ataca, **já em rede**
2. Mutantes e noite de hordas, com o Cristal (em rede)
3. Estruturas destrutíveis, reparo, torres a vapor; sistema de 3 caminhos com 1 torre (em rede)
4. Dia cronometrado: coleta e craft; materiais variáveis; 1 arma, 1 armadura, 1 acessório com 3 caminhos
5. Caído/reviver + co-op local (tela dividida dinâmica)
6. Mapa procedural + meta-progressão + save + troca de mapa
7. Conexão pela internet
8. Arte final, som, lore, conteúdo e polimento

**Fase atual:** 0 (ajustando o project.godot: pixel art e renderizador Compatibility).
