export const MVP_RULES_V1 = {
  version: 'MVP_RULES_V1',
  attendanceDrop: {
    warningChangePercentage: -10,
    highChangePercentage: -20,
  },
  memberFrequencyDrop: {
    warningChangePercentage: -40,
    highChangePercentage: -60,
    minimumReferenceAccesses: 4,
    minimumAbsoluteDrop: 2,
  },
  prolongedAbsence: {
    warningDays: 10,
    highDays: 21,
    minimumHistoricalFrequencyPerWeek: 1,
  },
  unusuallyLowOccupancy: {
    warningChangePercentage: -25,
    highChangePercentage: -40,
    minimumReferenceSharePercentage: 5,
    minimumReferenceCount: 20,
  },
} as const;
