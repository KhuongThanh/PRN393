using E_Learning.Domain.Quiz.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Quiz.Controllers
{
    [Route("api/topics")]
    [ApiController]
    [Authorize]
    public class QuizCatalogController : ControllerBase
    {
        private readonly IQuizCatalogService _quizCatalogService;

        public QuizCatalogController(IQuizCatalogService quizCatalogService)
        {
            _quizCatalogService = quizCatalogService;
        }

        [HttpGet("{topicId:guid}/quizzes")]
        public async Task<IActionResult> GetQuizzesByTopic(Guid topicId)
        {
            var result = await _quizCatalogService.GetQuizzesByTopicAsync(topicId);
            return Ok(result);
        }
    }
}