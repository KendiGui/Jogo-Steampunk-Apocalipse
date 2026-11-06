# GDD (rascunho 7) — Jogo Sem Nome (roguelike steampunk apocalíptico)

> Status: briefing. **[A DEFINIR]** = não decidido.

## 1. Visão geral
- **Gênero:** roguelike co-op de sobrevivência com defesa de base.
- **Visão:** top-down, pixel art.
- **Tema:** apocalipse steampunk com toque de fantasia. Sensação constante de **escassez**.
- **Jogadores:** 1 a 4. **Online é o foco principal** (até 4). **Co-op local até 2 jogadores.**
- **Motor:** Godot 4 (GDScript).
- **Tipo de projeto:** hobby, sem prazo, com qualidade. Fase a fase, cada fase jogável.

## 2. Ambientação e lore (inicial)
- Mundo pós-apocalíptico steampunk. Pessoas e animais sofreram **mutações**: alguns viraram criaturas grandes e grotescas, outros pequenas e ágeis.
- No centro do acampamento há um **Cristal de Energia**, a esperança de cura das mutações.
- Lore será construída aos poucos.

## 3. Loop principal
1. **Dia (cronometrado, 5 minutos):** coletar e craftar só o essencial: armaduras, armas, acessórios ou defesas.
2. **Noite:** hordas de mutantes atacam o acampamento. Objetivos: **não morrer** e **impedir que o Cristal seja destruído**.
3. Repete dia → noite com dificuldade crescente.
4. **Progressão de mapa:** ao atingir um progresso X no mapa atual, avança para um **novo mapa e novo acampamento**.
5. **Derrota:** todos os jogadores caídos **ou** Cristal destruído.
6. **Meta-progressão:** todo progresso gera recompensa permanente; nunca voltar totalmente do zero.
7. **Cada run exige uma estratégia nova**, adaptada aos materiais que o jogo gerar.

## 4. Decisões já tomadas
- Run dura até a derrota; dificuldade escala por noite.
- **Reviver:** enquanto pelo menos um jogador estiver vivo. No solo, a primeira derrota encerra a run.
- **Cristal destruído = derrota.**
- Dia com cronômetro de 5 minutos (ajustável).
- Noite = tower defense + ação, com o Cristal como núcleo.
- Mapa procedural, com biomas/fases diferentes.
- **Co-op local: máximo 2 jogadores**, tela dividida dinâmica. **3 e 4 jogadores somente online.**
- **Tudo que dá buff tem 3 caminhos de aprimoramento:** armas, torres, armaduras e acessórios.
- **Novos caminhos são desbloqueados pela meta-progressão.**
- **Materiais variam por run:** nem sempre haverá material para um caminho, arma ou defesa; o jogador adapta a estratégia ao que o jogo gerar.
- **Progresso X no mapa leva a um novo mapa / novo acampamento.**
- Arte híbrida: packs prontos + placeholders por script + edição manual.

## 5. Identidade steampunk (mecânicas)
- **Torres** são mecanismos a vapor.
- **Armaduras** com bônus de vapor; **materiais condutores** de eletricidade.
- **Armas:** jatos de vapor que empurram; pressão acumulada causa dano em área.
- **[IDEIA]** Materiais ligados a temas de caminho (ex.: carvão → pressão/vapor; cobre → eletricidade), para o material disponível sugerir a estratégia.

## 6. Itens e caminhos de aprimoramento
- **Categorias:** armas, torres/defesas, armaduras, acessórios.
- **Cada item tem 3 caminhos.** Exemplo — **Canhão a vapor:** A) dano em área; B) alcance; C) a definir.
- Caminhos extras/novos itens desbloqueados entre runs.
- **[A DEFINIR]:** caminhos exclusivos ou misturáveis; níveis por caminho; upgrade de dia e/ou noite; recursos compartilhados ou individuais.
- **Técnico:** itens e caminhos como **dados** (Resources do Godot).

## 7. Materiais e aleatoriedade
- Materiais disponíveis variam a cada run (geração procedural).
- A escassez força escolhas e estratégias diferentes.
- **[A DEFINIR]:**
  1. **Garantia mínima:** materiais básicos sempre disponíveis para evitar runs impossíveis (principalmente no solo)?
  2. Biomas favorecem certos materiais?
  3. Lista de materiais (comuns, raros).
  4. Existe troca/conversão de materiais (ex.: desmontar itens)?

## 8. Meta-progressão e mapas
- **Princípio:** todo progresso dá recompensa; nunca voltar do zero sem nada.
- **Preferência:** desbloquear **opções** (caminhos, itens, materiais) em vez de aumentar stats.
- **Mapas:** progresso X num mapa leva a um novo mapa com novo acampamento.
- **[A DEFINIR]:**
  1. Troca de mapa **dentro da run** ("atos") ou **desbloqueio entre runs**, ou combinação?
  2. Se dentro da run: o que é levado para o novo acampamento?
  3. O que define o "progresso X"?
  4. Moeda da meta-progressão.

## 9. Inimigos (arquétipos iniciais)
- **Brutamontes:** grandes, lentos, muita vida, focam estruturas e o Cristal.
- **Ágeis:** pequenos, rápidos, em grupo, flanqueiam.
- Outros **[A DEFINIR]**.

## 10. Arquitetura (base técnica)
- **Multiplayer online desde a Fase 1** (host-autoritativo, High-Level Multiplayer do Godot).
- **Co-op local** reaproveita o mesmo código.
- **Mapa e materiais procedurais por seed** compartilhada.
- **Conteúdo orientado a dados** (Resources): itens, caminhos, materiais, inimigos, mapas.
- **Save de meta-progressão** — **[A DEFINIR]** em multiplayer: progresso de quem conta?
- **Git desde o primeiro dia.**
- Testes de rede: 2 janelas no mesmo PC → rede local → internet.
- Conexão pela internet: **[A DEFINIR]**.

## 11. Roadmap oficial
| Fase | Objetivo |
|---|---|
| 0 | Básico do Godot + Git/GitHub |
| 1 | Personagem top-down que anda e ataca, **já em rede** |
| 2 | Mutantes e noite de hordas, com o Cristal (em rede) |
| 3 | Estruturas destrutíveis, reparo, torres a vapor; **sistema de 3 caminhos** com 1 torre (em rede) |
| 4 | Dia cronometrado: coleta e craft; materiais variáveis; 1 arma, 1 armadura, 1 acessório com 3 caminhos |
| 5 | Caído/reviver + co-op local (2 jogadores, tela dividida dinâmica) |
| 6 | Mapa procedural + meta-progressão + save + troca de mapa |
| 7 | Conexão pela internet |
| 8 | Arte final, som, lore, mais conteúdo e polimento |

## 12. Arte
- Início: packs gratuitos + placeholders por script. Edição: Pixelorama ou Aseprite.
- Arte definitiva só depois de o jogo estar divertido.

## 13. Forma de trabalho
- Usuário iniciante em Godot, pouca prática de programação.
- Cada passo entrega **código completo**, com explicação parte por parte e o porquê.
- O usuário decide quando mexer por conta própria e pergunta quando quiser entender mais.

## 14. Riscos identificados
1. **Explosão de conteúdo:** 4 categorias × N itens × 3 caminhos × níveis. Crescer aos poucos, sempre com o sistema por dados.
2. **Runs impossíveis por azar** de materiais; precisa de garantia mínima.
3. **Online + local juntos** multiplica casos de teste.
4. **Dia de 5 min em mapa procedural:** distância até recursos precisa caber no tempo.
5. **Solo:** sem reviver; balanceamento de 1 a 4 jogadores.
6. **Muitos inimigos em rede:** limitar quantidade e simplificar IA.
7. **Save em multiplayer:** jogadores com progressos diferentes.

## 15. Perguntas em aberto
1. Nome do jogo.
2. Como reviver.
3. Misto: 2 locais + remotos?
4. Estilo de combate.
5. Plataforma: só PC?
6. Conexão online.
7. Detalhes dos caminhos (seção 6).
8. Materiais e aleatoriedade (seção 7).
9. Meta-progressão e troca de mapas (seção 8).
10. Outros benefícios de roguelike (ex.: 1 entre 3 bônus ao amanhecer)?
