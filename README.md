# Vanyukov Furnace Smelting SQL Analytics

## 1. Project overview (EN)

This repository contains an SQL portfolio project based on **copper concentrate smelting in a Vanyukov furnace**.  
The goal is to build a realistic relational database and analytical SQL queries that simulate how a data analyst or process engineer would:

- monitor smelting performance,
- analyse matte and slag quality,
- track process stability and overheating risks,
- evaluate the impact of technological parameters on key outputs.

The data in this project are **synthetic**, but all fields and relationships are inspired by real metallurgical practice. The synthetic dataset in this project covers a **3-year operational period** of the Vanyukov furnace

---

## 2. Key process parameters

The analytical focus of this project is on a single Vanyukov furnace and its heats (smelting campaigns).  
For each heat we analyse:

### 2.1 Matte composition (matte quality)

- Copper content in matte (% Cu)
- Iron content in matte (% Fe)

These indicators are used to assess whether the process reaches the target matte grade.

### 2.2 Slag composition (slag quality and losses)

- Copper content in slag (% Cu) — copper losses to slag  
- Iron content in slag (% Fe)  
- FeO content in slag (% FeO)  
- Fe₃O₄ content in slag (% Fe₃O₄)  
- Slag-forming additions (fluxes, kg or t)

These parameters are used to analyse:
- copper losses to slag,
- the FeO/Fe₃O₄ balance,
- the effect of slag-forming additions on slag quality and furnace operation.

### 2.3 Process and gas parameters

- Off-gas temperature (°C)

This characterises heat losses through off-gases and indicates potential problems with heat balance or draft.

### 2.4 Feed properties and operating conditions

- Moisture of copper concentrates (%)
- Blast rate (m³/h or Nm³/h of air/oxygen-enriched air)

These factors influence:
- thermal balance of the furnace,
- process stability,
- oxidation/reduction conditions in the bath.

### 2.5 Furnace lining condition and overheating zones

- Wall temperature (°C)
- Roof (arch) temperature (°C)
- Overheating zones (binary flag / category: presence, location, severity)
- Refractory wear rate (mm/day or mm/heat)

These indicators are used to:
- detect dangerous overheating conditions,
- assess refractory lifetime,
- identify operating modes that accelerate wear of the furnace lining.

---

## 3. Planned SQL analysis

Within this project, SQL will be used to answer questions such as:

- How does blast rate affect off-gas temperature?
- Under which conditions does copper content in slag increase (higher losses)?
- How do FeO and Fe₃O₄ contents correlate with slag copper losses?
- Which heats show signs of overheating based on wall and roof temperatures?
- How does concentrate moisture influence energy balance and gas temperature?
- Which operating modes are associated with higher refractory wear rates?

The repository will include:

- SQL scripts for schema creation,
- synthetic data generation (large dataset),
- analytical queries focused on process quality, energy efficiency and furnace stability.

---

## 4. Technologies

- SQL (relational database)
- Any SQL engine (e.g. SQLite / PostgreSQL / SQL Server) — to be specified in scripts and documentation

---

## 1. Описание проекта (RU)

Данный репозиторий содержит SQL-проект для портфолио, основанный на данных **объёдиненной плавки медных концентратов в печи Ванюкова**.  
Цель проекта — построить реалистичную реляционную базу данных и набор аналитических SQL-запросов, которые имитируют работу дата-аналитика или инженера-металлурга при:

- мониторинге хода плавки,
- анализе качества штейна и шлака,
- оценке устойчивости процесса и рисков перегрева,
- исследовании влияния технологических параметров на ключевые показатели.

Все данные в проекте **синтетические**, но структура и параметры вдохновлены реальной практикой цветной металлургии. Синтетический набор данных в проекте охватывает **трёхлетний период работы печи Ванюкова**.

---

## 2. Основные параметры процесса

Аналитический фокус проекта — одна печь Ванюкова и её отдельные плавки (heats).  
Для каждой плавки анализируются следующие группы параметров.

### 2.1 Состав штейна (качество штейна)

- Содержание меди в штейне (% Cu)
- Содержание железа в штейне (% Fe)

Эти показатели используются для оценки того, достигается ли требуемая марка штейна.

### 2.2 Состав шлака (качество шлака и потери)

- Содержание меди в шлаке (% Cu) — потери меди со шлаком  
- Содержание железа в шлаке (% Fe)  
- Содержание FeO в шлаке (% FeO)  
- Содержание Fe₃O₄ в шлаке (% Fe₃O₄)  
- Количество шлакообразующих добавок (флюсы, кг или т)

По этим параметрам анализируются:
- величина потерь меди со шлаком,
- соотношение FeO/Fe₃O₄,
- влияние шлакообразующих добавок на качество шлака и работу печи.

### 2.3 Параметры отходящих газов и тепловой режим

- Температура отходящих газов (°C)

Этот показатель характеризует потери тепла с газами и может указывать на проблемы с тепловым балансом или тягой.

### 2.4 Свойства шихты и режим дутья

- Влажность медных концентратов (%)  
- Расход дутья (м³/ч или нм³/ч воздуха / обогащённого кислородом дутья)

Эти параметры влияют на:
- тепловой баланс печи,
- устойчивость процесса,
- окислительно-восстановительные условия в ванне.

### 2.5 Состояние футеровки и зоны перегрева

- Температура стен печи (°C)
- Температура свода (кровли) печи (°C)
- Наличие и характеристики зон перегрева (флаг/категория: есть/нет, зона, степень)
- Скорость износа футеровки (мм/сутки или мм/плавку)

По этим данным можно:
- выявлять опасные режимы с перегревом,
- оценивать срок службы футеровки,
- определять режимы работы, ускоряющие износ огнеупоров.

---

## 3. Планируемый SQL-анализ

В рамках проекта с помощью SQL планируется отвечать на вопросы:

- Как расход дутья влияет на температуру отходящих газов?
- При каких режимах возрастает содержание меди в шлаке (потери меди)?
- Как связаны содержания FeO и Fe₃O₄ с потерями меди в шлаке?
- Какие плавки демонстрируют признаки перегрева по температуре стен и свода?
- Как влажность концентратов влияет на тепловой режим и температуру газов?
- Какие режимы сопровождаются повышенной скоростью износа футеровки?

В репозитории будут размещены:

- SQL-скрипты для создания схемы БД,
- генерация (или загрузка) большого синтетического набора данных,
- аналитические запросы, посвящённые качеству продукции, энергоэффективности и устойчивости работы печи.

---

## 4. Технологии

- SQL (реляционная база данных)
- Любая SQL-СУБД (например, SQLite / PostgreSQL / SQL Server) — уточняется в скриптах и документации
