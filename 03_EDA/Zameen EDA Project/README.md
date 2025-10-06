# Zameen.com Property Price Analysis

## Project Objective
The goal of this project is to extract actionable insights from property listings on Zameen.com. By analyzing pricing trends, neighborhood comparisons, and listing quality, the analysis aims to assist real estate investors in making informed decisions.

## Problem Statement
What drives property prices in Pakistan?  
This analysis seeks to identify the key factors influencing property prices in Pakistan based on the provided Zameen.com dataset. By exploring relationships between property features and their prices, we can gain insights into what makes a property more or less valuable in the Pakistani real estate market.

## Data
The dataset consists of property listings scraped from Zameen.com, including features such as:

- Title
- URL
- City
- Type
- Area
- Price
- Purpose
- Location
- Description
- Bedrooms, Bathrooms, and more

## Analysis Steps
1. **Data Loading and Initial Inspection:** Loaded the dataset and performed initial checks to understand structure, missing values, and duplicates.  
2. **Data Cleaning:** Removed unnecessary columns, dropped duplicate rows, and handled missing values using mode, median, and forward fill.  
3. **Data Transformation:** Cleaned and converted 'Price' and 'Area' columns into numerical formats.  
4. **Outlier Treatment:** Identified and capped outliers in 'Area', 'Price', 'Bedrooms', and 'Bathrooms' using the IQR method.  
5. **Feature Engineering:** Created new features like `Price_Numeric`, `Price_per_sqft`, and `Total_Rooms` for enhanced analysis.  
6. **Univariate and Bivariate Analysis:** Visualized distributions with histograms and box plots. Explored relationships using correlation heatmaps and violin/box plots comparing price with categorical features like City and Type.

## Key Insights
- Property prices and areas exhibit skewed distributions with significant outliers.  
- Number of bedrooms and bathrooms shows a stronger positive correlation with price than total area.  
- Price per square foot is highly correlated with overall price and is useful for comparing properties.  
- Property prices vary significantly across different cities and property types.

## Recommendations for Investors
- Prioritize the number of bedrooms and bathrooms as key price drivers.  
- Use price per square foot for comparing properties of different sizes and locations.  
- Conduct city-specific research to understand local market dynamics.  
- Analyze property type performance in target markets.  
- Investigate high-value properties to understand the luxury segment.  
- Consider detailed location features beyond just the city.  
- Incorporate additional data like property age, amenities, and market trends for more robust analysis.

## Next Steps
Further analysis could include:  

- Extracting more granular location-based features.  
- Developing predictive models to forecast property prices.  
- Analyzing the impact of property age and amenities on price.
