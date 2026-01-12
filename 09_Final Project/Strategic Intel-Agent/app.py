import os
import sqlite3
import smtplib
import streamlit as st
from typing import List, TypedDict
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# LangChain & Graph Imports
from langchain_openai import ChatOpenAI
from langchain_community.tools.tavily_search import TavilySearchResults
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.sqlite import SqliteSaver

# --- 1. PAGE SETUP ---
st.set_page_config(page_title="Strategic Intel-Agent", layout="wide", page_icon="🛡️")

st.markdown("""
    <style>
    .main { background-color: #f8f9fa; }
    .stButton>button { width: 100%; border-radius: 8px; height: 3em; font-weight: bold; transition: 0.3s; }
    .report-container { background-color: white; padding: 25px; border-radius: 12px; border: 1px solid #dee2e6; }
    </style>
    """, unsafe_allow_html=True)

# --- 2. SIDEBAR ---
with st.sidebar:
    st.image("https://cdn-icons-png.flaticon.com/512/2103/2103633.png", width=80)
    st.title("Settings & Tools")
    
    with st.expander("🔑 API Credentials", expanded=True):
        openai_key = st.text_input("OpenAI API Key", value=os.getenv("OPENAI_API_KEY", ""), type="password")
        tavily_key = st.text_input("Tavily API Key", value=os.getenv("TAVILY_API_KEY", ""), type="password")
        
    with st.expander("📧 Email Settings (SMTP)", expanded=True):
        sender_email = st.text_input("Your Gmail Address", value="ahmadsanafarooq@gmail.com")
        app_password = st.text_input("App Password", type="password")

    thread_id = st.text_input("Session ID", value="global_user_1")
    os.environ["OPENAI_API_KEY"] = openai_key
    os.environ["TAVILY_API_KEY"] = tavily_key

# --- 3. EMAIL TOOL ---
def send_email_smtp(content, recipient, sender, password):
    if not all([content, recipient, sender, password]): return False
    msg = MIMEMultipart()
    msg['From'], msg['To'], msg['Subject'] = sender, recipient, "Market Intelligence Report"
    msg.attach(MIMEText(content, 'plain'))
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587, timeout=10)
        server.starttls()
        server.login(sender, password)
        server.sendmail(sender, recipient, msg.as_string())
        server.quit()
        return True
    except Exception: return False

# --- 4. AGENT LOGIC ---
DB_PATH = "agent_memory.db"
class AgentState(TypedDict):
    company_name: str
    research_data: List[dict]
    iteration: int
    report: str

@st.cache_resource
def initialize_agent():
    llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

    def researcher(state: AgentState):
        # Initializing inside node to prevent the Tavily crash you saw earlier
        search_tool = TavilySearchResults(max_results=3)
        iter_count = state.get("iteration", 0)
        query = f"Financial SWOT and strategy for {state['company_name']} 2025"
        if iter_count > 0:
            query = f"Deep-dive business analysis for {state['company_name']} 2025"
        results = search_tool.invoke({"query": query})
        return {"research_data": results, "iteration": iter_count + 1}

    def writer(state: AgentState):
        context = "\n".join([f"Source: {r['url']}\nContent: {r['content']}" for r in state['research_data']])
        prompt = f"Write a professional SWOT for {state['company_name']}.\n\nDATA:\n{context}"
        response = llm.invoke(prompt)
        return {"report": response.content}

    builder = StateGraph(AgentState)
    builder.add_node("researcher", researcher)
    builder.add_node("writer", writer)
    builder.add_edge(START, "researcher")
    builder.add_edge("researcher", "writer")
    builder.add_edge("writer", END)
    
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    return builder.compile(checkpointer=SqliteSaver(conn), interrupt_before=["writer"])

agent_app = initialize_agent()
config = {"configurable": {"thread_id": thread_id}}

# --- 5. MAIN GUI ---
st.title("🛡️ Strategic Intel-Agent")

if "report_output" not in st.session_state:
    st.session_state.report_output = None

# Input Section
company = st.text_input("Target Company Name", placeholder="e.g. NVIDIA")
if st.button("🔍 Start Research"):
    st.session_state.report_output = None
    agent_app.invoke({"company_name": company, "iteration": 0}, config)
    st.rerun()

current_state = agent_app.get_state(config)

# --- SHOW RESEARCH AND THE TWO BUTTONS ---
if current_state.values.get("research_data"):
    st.divider()
    st.subheader("📋 Intelligence Briefing")
    
    with st.expander("📂 View Raw Research Data", expanded=True):
        for item in current_state.values["research_data"]:
            st.markdown(f"**Source:** {item['url']}")
            st.caption(item['content'])
            st.divider()

    # THE TWO OPTIONS YOU REQUESTED
    c1, c2 = st.columns(2)
    with c1:
        if st.button("✅ Approve & Generate SWOT", type="primary"):
            final_res = agent_app.invoke(None, config)
            st.session_state.report_output = final_res.get("report")
            st.rerun()
    with c2:
        if st.button("🔄 Data Insufficient: Search Again"):
            agent_app.update_state(config, {"research_data": []}, as_node="researcher")
            agent_app.invoke(None, config)
            st.rerun()

# --- 6. REPORT & EMAIL CENTER ---
if st.session_state.report_output:
    st.markdown("---")
    res_col, tool_col = st.columns([2, 1])

    with res_col:
        st.markdown("### 🏁 Final SWOT Report")
        st.markdown(f'<div class="report-container">{st.session_state.report_output}</div>', unsafe_allow_html=True)

    with tool_col:
        st.markdown("### 🚀 Email Delivery")
        email_target = st.text_input("Recipient Email")
        if st.button("📧 Send via Email"):
            if send_email_smtp(st.session_state.report_output, email_target, sender_email, app_password):
                st.success("Sent Successfully!")
            else:
                st.error("Check SMTP settings & App Password.")