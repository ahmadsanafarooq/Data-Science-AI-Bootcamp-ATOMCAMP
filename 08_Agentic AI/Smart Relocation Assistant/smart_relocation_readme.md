# README.md
# 🏠 Smart Relocation Assistant

The Smart Relocation Assistant is a multi-agent system built with **CrewAI** and deployed via **Streamlit** that helps users identify the best neighborhoods to live in a new city based on their budget, lifestyle, and work location.

It uses **gpt-4o-mini** as the LLM (Large Language Model) to provide fast and cost-effective reasoning.

---

## 🚀 Getting Started

Follow these steps to set up and run the application locally.

### 1. Prerequisites

* **Python:** Ensure you have Python **3.10** or newer installed.
* **API Keys:** You need two external API keys:
    * **OpenAI API Key (`OPENAI_API_KEY`)** – for the AI agents’ reasoning (the "Brain").
    * **Serper API Key (`SERPER_API_KEY`)** – for real-time Google search results (the "Eyes") to fetch rent prices and local details.

### 2. Installation

1. **Clone the Repository:**

```bash
git clone https://github.com/ahmadsanafarooq/Data-Science-AI-Bootcamp-ATOMCAMP/tree/main/07_Agentic_AI
cd smart-relocation-assistant
```

2. **Create and Activate Virtual Environment:**

```bash
python3 -m venv .venv
source .venv/bin/activate  # Use `.venv\Scripts\activate` on Windows
```

3. **Install Dependencies:**

```bash
pip install -r requirements.txt
```

### 3. Configuration (API Keys)

**Do not commit your actual keys to GitHub.** Use the `.env` file for local testing and set secrets directly on Hugging Face Spaces for deployment.

1. **Create `.env` File:**

```bash
cp .env.example .env
```

2. **Edit `.env`:** Open the new `.env` file and paste your secret keys:

```ini
# .env
# REPLACE THE PLACEHOLDERS BELOW WITH YOUR ACTUAL KEYS
OPENAI_API_KEY="sk-YOUR-OPENAI-API-KEY-HERE"
SERPER_API_KEY="YOUR-SERPER-API-KEY-HERE"
```

---

## ▶️ How to Run the Agent

Run the Streamlit application from your terminal:

```bash
streamlit run app.py
```

The application will automatically open in your web browser (usually at [http://localhost:8501](http://localhost:8501)).

---

## 🗑️ Example Prompts

The quality of the final recommendation depends heavily on the Lifestyle Preferences you provide.

| Target City | Max Rent | Lifestyle Preference | Expected Agent Action |
|------------|----------|-------------------|---------------------|
| New York, NY | $3,500 | Needs easy subway access to Midtown, strong nightlife, near good pizza. | City Scout focuses on accessibility; Financial Analyst checks $3500 affordability. |
| Denver, CO | $1,800 | Remote tech worker, loves hiking/climbing, brewery scene, quiet but close to the mountains. | City Scout searches for areas near trails and local breweries. |

---

## ⚙️ Crew Architecture

The Smart Relocation Assistant uses a sequential process to ensure research precedes financial analysis:

| Agent Role | LLM Used | Tool(s) Used | Primary Goal |
|------------|----------|--------------|--------------|
| City Neighborhood Scout | gpt-4o-mini | SerperDevTool | Identifies 5 neighborhoods matching lifestyle/commute. |
| Relocation Financial Analyst | gpt-4o-mini | SerperDevTool & CalculatorTool | Verifies costs, filters non-affordable options, and compiles the final ranked report. |


# .env.example

```ini
# .env.example
# Copy this file to a new file named .env and replace the placeholder values.
# This file is used for local development ONLY.
#
# IMPORTANT: Never commit your actual keys to GitHub!

OPENAI_API_KEY=""
SERPER_API_KEY=""
```

