import streamlit as st
import os
import sys
from crewai import Agent, Task, Crew, Process
from crewai.tools import BaseTool
from crewai_tools import SerperDevTool
from langchain_openai import ChatOpenAI 


st.set_page_config(page_title="Smart Relocation Assistant", page_icon="🏘️", layout="wide")

st.title("Smart Relocation Assistant")
st.markdown("Use AI Agents to find your perfect neighborhood based on budget and lifestyle.")

# --- 2. API KEY SETUP ---
# Fetch keys from environment variables (Hugging Face Secrets)
openai_api_key = os.getenv("OPENAI_API_KEY")
serper_api_key = os.getenv("SERPER_API_KEY")

if not (openai_api_key and serper_api_key):
    st.error(" API Keys not found!")
    st.warning("Please set OPENAI_API_KEY and SERPER_API_KEY in your Hugging Face Space 'Settings' -> 'Variables and secrets'.")
    st.stop()

# Set keys back into environment for the tools/libraries
os.environ["OPENAI_API_KEY"] = openai_api_key
os.environ["SERPER_API_KEY"] = serper_api_key

# --- 3. TOOL DEFINITIONS ---

# The Search Tool is now initialized here
search_tool = SerperDevTool()

# Custom Calculator Tool 
class CalculatorTool(BaseTool):
    name: str = "Budget Calculator"
    description: str = "Useful for calculating if a rent price fits within a budget. Input must be a mathematical expression."

    def _run(self, expression: str) -> str:
        try:
            # Safe evaluation of simple math
            return str(eval(expression))
        except:
            return "Error in calculation"

calc_tool = CalculatorTool()

# --- 4. LLM DEFINITION
gpt_4o_mini = ChatOpenAI(
    model="gpt-4o-mini",
    temperature=0.7 
)


# --- 5. STREAMLIT INPUTS ---
st.header("1. Enter Your Relocation Details")
col1, col2 = st.columns(2)
with col1:
    city = st.text_input("Target City", "Austin, TX")
    budget = st.number_input("Max Monthly Rent ($)", min_value=500, value=2500)
with col2:
    work_location = st.text_input("Work Location", "Downtown")
    
preferences = st.text_area("Lifestyle Preferences", "Walkable, near coffee shops, safe, good for young professionals")

# --- 6. AGENT & TASK DEFINITIONS (Defined in the function for cleaner scope) ---

def run_crew_analysis(city, work_location, budget, preferences):
    city_scout = Agent(
        role='City Neighborhood Scout',
        goal=f'Identify the top 3 neighborhoods in {city} that match these preferences: {preferences}.',
        backstory="You are a local expert who knows every corner of the city. You prioritize safety, commute, and lifestyle fit.",
        tools=[search_tool],
        llm=gpt_4o_mini, 
        verbose=True,
        allow_delegation=False
    )

    budget_analyst = Agent(
        role='Relocation Financial Advisor',
        goal=f'Assess the affordability of specific neighborhoods and ensure rent is within {budget}.',
        backstory="You are a pragmatic financial advisor. You strictly filter out any options that exceed the user's budget.",
        tools=[search_tool, calc_tool],
        llm=gpt_4o_mini, 
        verbose=True,
        allow_delegation=False
    )

    scout_task = Task(
        description=f"Search for neighborhoods in {city} that are: {preferences}. Consider commute to {work_location}. Select top 5 candidates.",
        expected_output="List of 5 neighborhoods with vibe descriptions.",
        agent=city_scout
    )

    analysis_task = Task(
        description=f"For the 5 neighborhoods found, search current average rent for a 1-bedroom. Filter out any where rent > {budget}. Calculate remaining budget.",
        expected_output="Filtered list of affordable neighborhoods with costs.",
        agent=budget_analyst
    )

    report_task = Task(
        description="""Compile a final report. Rank top 3 affordable neighborhoods. Include: Neighborhood Name, Vibe, Rent Cost, Remaining Budget, and one Local Highlight. Format as clear Markdown.""",
        expected_output="Markdown formatted relocation guide.",
        agent=budget_analyst
    )

    # --- CREW EXECUTION ---
    relocation_crew = Crew(
        agents=[city_scout, budget_analyst],
        tasks=[scout_task, analysis_task, report_task],
        process=Process.sequential,
        llm=gpt_4o_mini 
    )

    return relocation_crew.kickoff()

# --- 7. BUTTON TRIGGER ---
if st.button("Start Research", type="primary"):
    with st.spinner('AI Agents are scouting neighborhoods and crunching numbers...'):
        try:
            result = run_crew_analysis(city, work_location, budget, preferences)
            
            # Display Results
            st.success("Research Complete!")
            st.markdown("### Your Relocation Plan")
            st.markdown(result)
            
        except Exception as e:
            st.error("An error occurred during crew execution. This often means a temporary API issue or a failure to parse a search result.")
            st.exception(e)
            st.markdown("---")
            st.warning("Please wait a few minutes (for rate limit cooldown) and try again, or check your API keys.")