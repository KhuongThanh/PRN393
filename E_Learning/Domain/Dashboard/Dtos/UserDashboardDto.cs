namespace E_Learning.Domain.Dashboard.Dtos
{
    public class UserDashboardDto
    {
        public int LearnedTopicCount { get; set; }
        public int LearnedWordCount { get; set; }
        public int FavoriteWordCount { get; set; }

        public int TargetDailyWords { get; set; }
        public int TodayStudiedWordCount { get; set; }
        public int DailyProgressPercent { get; set; }

        public LatestQuizResultDto? LatestQuiz { get; set; }
    }
}
