using E_Learning.Domain.Quiz.Dtos.QuizAttempt;
using E_Learning.Domain.Quiz.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Quiz.Controllers
{
    [Route("api")]
    [ApiController]
    [Authorize]
    public class QuizAttemptController : ControllerBase
    {
        private readonly IQuizAttemptService _quizAttemptService;

        public QuizAttemptController(IQuizAttemptService quizAttemptService)
        {
            _quizAttemptService = quizAttemptService;
        }

        [HttpPost("quizzes/{quizId:guid}/start")]
        public async Task<IActionResult> StartQuiz(Guid quizId)
        {
            var userId = GetCurrentUserId();
            var result = await _quizAttemptService.StartQuizAsync(quizId, userId);
            return Ok(result);
        }

        [HttpGet("quiz-attempts/{attemptId:guid}/questions")]
        public async Task<IActionResult> GetQuestions(Guid attemptId)
        {
            var userId = GetCurrentUserId();
            var result = await _quizAttemptService.GetQuizQuestionsAsync(attemptId, userId);
            return Ok(result);
        }

        [HttpPost("quiz-attempts/{attemptId:guid}/answers")]
        public async Task<IActionResult> SaveAnswer(Guid attemptId, [FromBody] SaveQuizAnswerRequest request)
        {
            var userId = GetCurrentUserId();
            var result = await _quizAttemptService.SaveAnswerAsync(attemptId, userId, request);
            return Ok(result);
        }

        [HttpPost("quiz-attempts/{attemptId:guid}/submit")]
        public async Task<IActionResult> Submit(Guid attemptId)
        {
            var userId = GetCurrentUserId();
            var result = await _quizAttemptService.SubmitQuizAsync(attemptId, userId);
            return Ok(result);
        }

        private Guid GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("userId")?.Value
                              ?? User.FindFirst("UserId")?.Value
                              ?? User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrWhiteSpace(userIdClaim))
                throw new Exception("UserId claim not found in token.");

            return Guid.Parse(userIdClaim);
        }
    }
}