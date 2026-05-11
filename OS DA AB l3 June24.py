#!/usr/bin/env python
# coding: utf-8

# <h3>SciPy</h3>
# 
# ### Що таке SciPy
# 
# 
# SciPy (Scientific Python) — це бібліотека для Python, яка надає набір інструментів для виконання наукових та інженерних обчислень. SciPy побудована на основі бібліотеки NumPy та складається з кількох модулів, із яких нам буде потрібний модуль для статистичних обчислень — scipy.stats.
# 
# scipy.stats надає широкий спектр функцій для статистичного аналізу, наприклад:
# 
# * Функції для роботи за статистичними розподілами;
# * Функції описової статистики;
# * Функції для тестування гіпотез тощо.
# 
# 
# За допомогою функцій тестування гіпотез із модуля scipy.stats ми маємо змогу оцінити статистичну значущість результатів нашого A/B тесту.

# In[4]:


import pandas as pd
import numpy as np
#test


# ### Контрольна група
# 
# * Кількість користувачів у групі: 7 015
# * Кількість конверсій у групі: 139
# * Значення конверсії: 1.98%
# 
# 
# ### Альтернативна група
# 
# * Кількість користувачів у групі: 6 987
# * Кількість конверсій у групі: 314
# * Значення конверсії: 4.49%

# In[20]:


test_data = pd.DataFrame(data={'test_group': ['a']*7015 + ['b']*6987,
                               'conversion': [1]*139 + [0]*(7015-139) + [1]*314 + [0]*(6987-314)})

print(test_data)
# Перевіримо, чи все коректно згенерували:
print(test_data.groupby('test_group').describe())
test_data.to_excel('Z:\\own\\goit\\data_ab_test.xlsx')


# ### Критерій Стʼюдента
# 
# scipy.stats.ttest_ind — Тест (Тест Стʼюдента) для двох незалежних вибірок.
# 
# 
# 
# ### Нульова гіпотеза: середні двох незалежних вибірок не відрізняються.
# 
# 
# 
# Основні параметри функції:
# 
# * a, b — масиви значень у двох вибірках;
# * axis — напрямок обчислень у випадку використання багатовимірних масивів;
# * equal_var — параметр, який вказує, чи припускається рівність дисперсій. За замовчуванням, True;
# * alternative — визначає альтернативну гіпотезу.
#      * less — середнє вибірки a менше за середнє вибірки b;
#      * greater — середнє вибірки a більше за середнє вибірки b;
#      * two-sided — середні вибірок відрізняються.
# 

# In[21]:


from scipy import stats

alpha = 0.01

statistic, pvalue = stats.ttest_ind(
                                    test_data[test_data['test_group'] == 'b']['conversion'],
                                    test_data[test_data['test_group'] == 'a']['conversion'],
                                    alternative='two-sided',
                                    equal_var = False)

print(f't-statistic: {round(statistic, 2)}, p-value: {round(pvalue, 3)}')

if pvalue < alpha:
    print('The difference is statistically significant, Null Hypothesis is rejected.')
else:
    print('The difference is insignificant, Null Hypothesis cannot rejected.')


# ### Критерій Хі-квадрат
# 
# 
# 
# Критерій Хі-квадрат, або Chi-squared — ще один із популярних критеріїв тестування гіпотез, призначений для роботи з категоріальними даними. Цей критерій перевіряє залежність змінної від категорії, тобто у випадку A/B тесту — чи залежить метрика, яку ми аналізуємо, від тестової групи, в яку потрапив користувач.
# 
# 
# 
# У SciPy Критерій Хі-квадрат представлений функцією stats.chi2_contingency.
# 
# 
# 
# ### Нульова гіпотеза: змінна є незалежною від категорії, під яку вона підпадає.
# 
# 
# 
# Основні параметри функції:
# 
# * observed — контингентна таблиця, що містить спостережені частоти (тобто кількість випадків) у кожній категорії. По суті, це зведена таблиця, в якій рядок — це категорія, стовпчик — значення змінної, а значення в таблиці — кількість спостережень.

# In[22]:


from scipy import stats

alpha = 0.05

observed = pd.crosstab(test_data['test_group'].values, test_data['conversion'].values)

print(observed)

print(stats.chi2_contingency(observed))

statistic, pvalue, dof, expected_values = stats.chi2_contingency(observed)

print(f't-statistic: {round(statistic, 2)}, p-value: {round(pvalue, 2)}')

if pvalue < alpha:
    print('The difference is statistically significant, Null Hypothesis is rejected.')
else:
    print('The difference is insignificant, Null Hypothesis cannot rejected.')


# <h3>Permutation test</h3>

# ### Тести з перестановками
# Permutation test, або тест з перестановками — метод статистичного тестування, який базується на перемішуванні даних між групами для оцінки статистичної значущості результатів.
# 
# 
# 
# Основна ідея полягає в тому, щоб за допомогою перестановок зрозуміти, з якою ймовірністю ми отримаємо такі самі або більш екстремальні результати, якщо нульова гіпотеза справджується. Для цього проводиться багато перемішувань, для кожного з яких обчислюється статистика, а потім ми порівнюємо фактичну статистику з отриманим розподілом.
# 
# 
# 
# Алгоритм, якби ми обрали критерій Стʼюдента, виглядає приблизно так:
# 
# 1. Розраховуємо t-статистику на тих даних, які маємо. Це і буде наша фактична статистика t0;
# 2. Тепер обʼєднаємо всі спостереження в одну групу й розділимо на дві рівних заново випадковим чином;
# 3. Розрахуємо t-статистику на цих нових двох групах;
# 4. Повертаємось до кроку 2, потім — до кроку 3. Робимо все те ж саме n разів;
# 5. Тепер усі отримані t-статистики упорядковуємо у зростаючому порядку — це наш емпіричний розподіл.
# 
# 
# Тепер якщо наше t0 не потрапляє в середні 95% значень емпіричного розподілу, ми можемо відкидати нульову гіпотезу з імовірністю 95%.

# In[10]:


from scipy import stats

def statistic(x, y):
    return stats.ttest_ind(x, y).statistic

alpha = 0.05
    
x = test_data[test_data['test_group'] == 'a']['conversion']
y = test_data[test_data['test_group'] == 'b']['conversion']

results = stats.permutation_test((y, x), statistic, n_resamples=100, alternative='two-sided' )

print(f'statistic: {round(results.statistic, 2)}, p-value: {round(results.pvalue, 2)}')

if results.pvalue < alpha:
    print('The difference is statistically significant, Null Hypothesis is rejected.')
else:
    print('The difference is insignificant, Null Hypothesis cannot rejected.')


# In[11]:


from scipy import stats

def statistic(x, y):
    return stats.ttest_ind(x, y).statistic

alpha = 0.05
    
x = test_data[test_data['test_group'] == 'a']['conversion']
y = test_data[test_data['test_group'] == 'b']['conversion']

results = stats.permutation_test((x, y), statistic, n_resamples=100, alternative='two-sided',)

print(results)

print(f'statistic: {round(results.statistic, 2)}, p-value: {round(results.pvalue, 2)}')

if results.pvalue < alpha:
    print('The difference is statistically significant, Null Hypothesis is rejected.')
else:
    print('The difference is insignificant, Null Hypothesis cannot rejected.')


# In[12]:


import matplotlib.pyplot as plt
import seaborn as sns

plt.figure(figsize = (10,6))
sns.histplot(results.null_distribution)
plt.show()


# In[45]:


from scipy import stats

def statistic(x,y):
    observed = pd.crosstab(x,y)
    return stats.chi2_contingency(observed)[0]  # chi2 statistic

alpha = 0.05

results = stats.permutation_test((test_data['test_group'].values, test_data['conversion'].values), 
                                 statistic, 
                                 n_resamples=500)

print(f'statistic: {round(results.statistic, 2)}, p-value: {round(results.pvalue, 2)}')

if results.pvalue < alpha:
    print('The difference is statistically significant, Null Hypothesis is rejected.')
else:
    print('The difference is insignificant, Null Hypothesis cannot rejected.')


# <h3>Visualization</h3>

# In[46]:


import matplotlib.pyplot as plt
import seaborn as sns

plt.figure(figsize=(8, 6))
sns.barplot(x=test_data['test_group'], 
            y=test_data['conversion'], 
            ci = 95 # Confidence Intervals для значення алфа = 5%
           )

plt.title('A/B Test Results')
plt.xlabel('Group')
plt.ylabel('Mean')

plt.show()


# In[54]:


get_ipython().run_line_magic('pinfo', 'sns.barplot')


# In[14]:


import matplotlib.pyplot as plt
import seaborn as sns

plt.figure(figsize=(8, 6))
sns.barplot(x=test_data['test_group'], 
            y=test_data['conversion'], 
            errorbar='sd') # Для стандартної помилки задаємо sd, а не число

plt.title('Mean Comparison with Standart Error')
plt.xlabel('Group')
plt.ylabel('Mean')

plt.show()


# In[16]:


import seaborn as sns

plt.figure(figsize=(10, 6))

sns.kdeplot(stats.norm.rvs(size=1000))
sns.kdeplot(stats.norm.rvs(size=1000))

plt.title('Distribution of A/B Groups')
plt.xlabel('Value')
plt.ylabel('Frequency')

plt.legend(['A', 'B'])
plt.show()


plt.figure(figsize=(10, 6))

sns.histplot(stats.norm.rvs(size=1000))
sns.histplot(stats.norm.rvs(size=1000))

plt.title('Histogram of A/B Groups')
plt.xlabel('Value')
plt.ylabel('Frequency')

plt.legend(['A', 'B'])
plt.show()


# In[17]:


import seaborn as sns

# Перемішуємо дані, оскільки зараз вони упорядковані за значенням конверсії
# Якби ми використовували реальні дані - тут мало б бути сортування за датою та часом
test_data = test_data.sample(frac=1).reset_index(drop=True)

# Рахуємо кумулятивне середнє - це і є зміна конверсії з плином часу
cumulative_metric_a = test_data[test_data['test_group'] == 'a']['conversion'].expanding().mean().reset_index(drop=True)
cumulative_metric_b = test_data[test_data['test_group'] == 'b']['conversion'].expanding().mean().reset_index(drop=True)

plt.figure(figsize=(10, 6))
plt.plot(cumulative_metric_a, label='A')
plt.plot(cumulative_metric_b, label='B')

plt.title('Cumulative Сonversion Rate Comparison')
plt.xlabel('Time')
plt.ylabel('Cumulative Сonversion Rate')

plt.legend()
plt.show()


# In[19]:


from scipy.stats import shapiro, anderson, kstest, normaltest

# Тест Шапіро-Уілка
shapiro_test = shapiro(test_data['conversion'].values)
print(f'Тест Шапіро-Уілка: статистика={shapiro_test.statistic}, p-значення={shapiro_test.pvalue}')

# Тест Андерсона-Дарлінга
anderson_test = anderson(test_data['conversion'].values)
print(f'Тест Андерсона-Дарлінга: статистика={anderson_test.statistic}, критичні значення={anderson_test.critical_values}, рівень значущості={anderson_test.significance_level}')

# Тест Колмогорова-Смирнова
kstest_test = kstest(test_data['conversion'].values, 'norm')
print(f'Тест Колмогорова-Смирнова: статистика={kstest_test.statistic}, p-значення={kstest_test.pvalue}')

# Тест Д'Агостіно
dagostino_test = normaltest(test_data['conversion'].values)
print(f'Тест Д\'Агостіно: статистика={dagostino_test.statistic}, p-значення={dagostino_test.pvalue}')


# In[ ]:


for i in range(1,30):
    # Ваша операція, яка виконується 30 разів
    print(f"Iteration {i}")

