USE master;
GO

IF DB_ID('CustomerAnalytics') IS NULL
    CREATE DATABASE CustomerAnalytics;
GO

USE CustomerAnalytics;
GO